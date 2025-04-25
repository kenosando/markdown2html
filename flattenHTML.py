from bs4 import BeautifulSoup
import base64
import os
from argparse import ArgumentParser
from pathlib import Path
from urllib.parse import unquote

args = ArgumentParser(description="Flatten HTML by converting SVG images to base64.")
args.add_argument(
    "-i", "--input", type=str, required=True, help="Input HTML file path."
)
args.add_argument(
    "-o", "--output", type=str, required=True, help="Output HTML file path."
)

args = args.parse_args()

assert Path(args.input).exists(), f"Input file {args.input} does not exist."
assert Path(args.input).suffix == ".html", "Input file must be an HTML file."

with Path(args.input).open("r", encoding="utf-8") as f:
    soup = BeautifulSoup(f, "html.parser")

for img in soup.find_all("img"):
    src = unquote(img.get("src", ""))
    if src.endswith(".svg") and os.path.exists(src):
        with Path(src).open("rb") as svg_file:
            encoded = base64.b64encode(svg_file.read()).decode("utf-8")
            img["src"] = f"data:image/svg+xml;base64,{encoded}"

with Path(args.output).open("w", encoding="utf-8") as f:
    f.write(str(soup))
