"""Copy the production Angular build to the public directory used by Flask and Vercel."""

from pathlib import Path
import shutil


root = Path(__file__).resolve().parents[1]
source = root / "frontend" / "dist" / "frontend" / "browser"
destination = root / "public"

if not (source / "index.html").is_file():
    raise SystemExit("Build Angular first: cd frontend; npm run build")

if destination.exists():
    shutil.rmtree(destination)
shutil.copytree(source, destination)
print(f"Synced Angular build to {destination}")
