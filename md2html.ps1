param (
    [string]$File
)

$config = Get-Content -Path ${PSScriptRoot}\config.json | ConvertFrom-Json

# Check if the file exists
if (-Not (Test-Path $File)) {
    Write-Host "File not found: $File"
    return
}

$MarkdownFilePath = Get-Item -Path $File
$MermaidFilename = @($MarkdownFilePath.BaseName,".mermaid.md") -join ''
$Title = $MarkdownFilePath.BaseName
$OutputFilename = @($MarkdownFilePath.BaseName,".html") -join ''
$TempFilename = (New-Item -Path C:\Temp -Name $OutputFilename -ItemType File -Force)
$DestinationPath = $MarkdownFilePath.DirectoryName
$DestinationFile = (New-Item -Path $DestinationPath -Name $OutputFilename -ItemType File -Force)

Write-Host "MERMAID: Converting $($MarkdownFilePath.Name) to $($MermaidFilename) ..."

& $config.MmdcPath -q -i $MarkdownFilePath -o $MermaidFilename 

Write-Host "PANDOC: Converting $($MermaidFilename) to $($TempFilename) ..."

& $config.PandocPath $MermaidFilename --from markdown --template="$($PSScriptRoot)\\template.html" -o $TempFilename -M title=$Title -M date="$(Get-Date -Format 'yyyy-MM-dd')"

Write-Host "FLATTEN HTML: Converting $($TempFilename) to $($destinationFile.Name) ..."

& $config.PythonPath ${PSScriptRoot}\flattenHTML.py -i $TempFilename -o $DestinationFile

Remove-Item -Path $TempFilename -Force
Remove-Item -Path $MermaidFilename -Force
Get-ChildItem -Path $DestinationPath -Filter "${Title}*.svg" | Remove-Item -Force
