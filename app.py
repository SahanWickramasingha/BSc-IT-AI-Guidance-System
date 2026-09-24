"""Flask web entry point for the OUSL IT career guidance system."""

import os
from pathlib import Path

from flask import Flask, jsonify, request, send_from_directory

from guidance import ALGORITHMS, GOALS, STARTS, find_paths


PUBLIC = Path(__file__).resolve().parent / "public"
app = Flask(__name__, static_folder=None)


@app.get("/")
def index():
    return send_from_directory(PUBLIC, "index.html")


@app.get("/<path:filename>")
def local_asset(filename):
    """Serve the built UI locally; Vercel serves public/ assets from its CDN."""
    return send_from_directory(PUBLIC, filename)


@app.post("/find_path")
def find_path():
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify(error="Send a JSON object with al_status, job_goal, and algorithm."), 400

    al_status = data.get("al_status")
    job_goal = data.get("job_goal")
    algorithm = data.get("algorithm")
    if not all(isinstance(value, str) for value in (al_status, job_goal, algorithm)) or (
        al_status not in STARTS or job_goal not in GOALS or algorithm not in ALGORITHMS
    ):
        return jsonify(error="Invalid selection. Choose a listed A/L status, job, and algorithm."), 400

    return jsonify(results=find_paths(al_status, job_goal, algorithm))


if __name__ == "__main__":
    app.run(host=os.environ.get("HOST", "0.0.0.0"), port=int(os.environ.get("PORT", "8000")))
