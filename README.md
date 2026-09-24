# BSc IT AI Guidance System — Angular + Flask

The original OUSL career guidance project has been converted from SWI-Prolog to a Python Flask API with an Angular frontend. The 36 career-path rules, four career goals, and DFS, BFS, and A* options are included. No Prolog installation is needed.

The responsive homepage uses the supplied BSc IT AI Guidance System logo in its header and browser icon. Selecting an A/L result, career, or search method calls the Flask API and updates the estimated months, highlighted destination, and step-by-step routes. On desktop, click or focus a destination on the route map to select it; an animated light travels along the route. Phones show a readable vertical journey and career buttons instead of squeezing the desktop SVG. The count-up, glowing destination, logo, and route cards animate subtly and respect reduced-motion settings. The diagram is illustrative; use the step-by-step list for the complete route and its estimated duration.

## Run on Windows

Open PowerShell inside the extracted project folder or the updated GitHub clone, then run:

```powershell
py -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

Open **http://127.0.0.1:8000/** in a browser. The Angular production build is already included in the ZIP; Node.js is only needed to edit and rebuild the UI. Stop the server with `Ctrl+C`.

The desktop layout is sized to feel like the earlier 80% browser screenshot at normal **100%** browser zoom. Press `Ctrl+0` in Chrome to reset zoom after upgrading. Mobile and tablet layouts keep readable type and full-size controls.

## Update the existing GitHub repository

The [existing BSc-IT-AI-Guidance-System repository](https://github.com/SahanWickramasingha/BSc-IT-AI-Guidance-System) can be converted in place. On Windows, extract this ZIP, open PowerShell in the extracted `BSc-IT-AI-Guidance-System-Flask` folder, and run:

```powershell
.\update-existing-repo.ps1
```

The script makes a fresh clone of your existing GitHub repository beside the extracted folder. It removes the old `Project/Bsc IT.pl` and `Project/index.html`, copies the Flask and Angular source into the repository root, then stages and lists the changes. The script does **not** change the existing repo on GitHub by itself. After you review the list of changes, run the two `git -C ... commit` and `git -C ... push origin HEAD` commands shown by the script. GitHub may ask you to sign in. Run `python app.py` inside the cloned repository after installing `requirements.txt`.

If PowerShell prevents the local script from running, open a PowerShell terminal in the extracted folder and run `powershell -ExecutionPolicy Bypass -File .\update-existing-repo.ps1`. The included `.gitignore` excludes dependencies and local configuration secrets. `frontend/dist` stays tracked so Flask can serve the UI without rebuilding Angular.

### View from a phone or another computer

With the Flask app running, connect both devices to the same Wi-Fi. Find the computer's IPv4 address with `ipconfig`, then open `http://YOUR_COMPUTER_IP:8000/` on the other device. Allow Python through the Windows firewall for your private network if prompted. The app listens on all local network interfaces by default; set `HOST=127.0.0.1` to limit access to the same computer. Access from any device over the internet requires deploying the Flask app to a host and opening its public URL; a local `127.0.0.1` URL only works on its own device. This development server is for local use.

## Edit the Angular UI

Install Node.js 22.22.3+ or 24.15+ to edit this Angular 22 UI. In one terminal run the Flask server as above. In another terminal:

```powershell
cd frontend
npm install
npm start
```

Open **http://localhost:4200/** for live UI updates. The Angular dev server forwards `/find_path` to Flask on port 8000. To update the version served by Flask on port 8000, run `npm run build` inside `frontend`, then refresh the Flask page. If Flask is already running, restarting it also works.

On macOS or Linux, activate the environment with `source .venv/bin/activate` and use `python3` if needed. To change the port, set the `PORT` environment variable before running the app.

## Project files

| File | Purpose |
| --- | --- |
| `app.py` | Flask API, input validation, and built Angular file serving |
| `guidance.py` | Python DFS, BFS, and A* search |
| `career_paths.json` | Career graph converted from the 36 original Prolog `path/4` facts |
| `frontend/src/app/` | Angular component, form, and results interface |
| `frontend/src/styles.css` | Responsive design |
| `frontend/public/brand-logo.png` | Supplied project logo used in the header and browser icon |
| `frontend/dist/frontend/browser/` | Ready-to-run Angular build served by Flask |

`POST /find_path` accepts JSON like `{"al_status":"pass","job_goal":"ai_job","algorithm":"a_star"}` and returns a `results` list. Available status values are `pass` and `fail`; jobs are `se_job`, `ce_job`, `ai_job`, and `ui_job`; algorithms are `dfs`, `bfs`, and `a_star`.

- DFS returns all simple paths and their total months.
- BFS returns the first path with the fewest steps, following the graph's original edge order.
- A* uses the same zero heuristic as the original project, so it finds the shortest total time by uniform-cost search. Equal-cost alternatives may be returned in a different order than the Prolog implementation.

Times are the original project's estimates and should be checked against current OUSL program requirements before use for academic decisions.
