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

base_path = Path(args.input).parent

with Path(args.input).open("r", encoding="utf-8") as f:
    soup = BeautifulSoup(f, "html.parser")

for img in soup.find_all("img"):
    src = Path(base_path)/unquote(img.get("src", ""))
    if src.suffix in (".svg",):
        with Path(src).open("rb") as svg_file:
            encoded = base64.b64encode(svg_file.read()).decode("utf-8")
            img["src"] = f"data:image/svg+xml;base64,{encoded}"
    elif src.suffix in (".png",):
        with Path(src).open("rb") as png_file:
            encoded = base64.b64encode(png_file.read()).decode("utf-8")
            img["src"] = f"data:image/png;base64,{encoded}"
    elif src.suffix in (".jpg",".jpeg"):
        with Path(src).open("rb") as jpg_file:
            encoded = base64.b64encode(jpg_file.read()).decode("utf-8")
            img["src"] = f"data:image/jpeg;base64,{encoded}"

with Path(args.output).open("w", encoding="utf-8") as f:
    f.write(str(soup))
