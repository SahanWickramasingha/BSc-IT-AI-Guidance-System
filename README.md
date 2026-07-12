# BSc IT AI Guidance System – OUSL 🎓

**Find the path to your dream job.**

An AI-powered career guidance system built in **Prolog**, designed for students who have finished their A/Levels (or are already enrolled) and want to understand how to reach their dream IT career through the Open University of Sri Lanka (OUSL).

The system maps out a relatively accurate path — along with a rough time estimate — to help you become a professional in one of four IT career tracks:

- 💻 Software Engineer
- 🔒 Cybersecurity Engineer
- 🤖 AI Engineer
- 🎨 UI/UX Designer

It can be used through a **console interface** or a **web-based GUI**.

## Search Algorithms Used

This project uses three classic AI search algorithms, each serving a different purpose:

| Algorithm | Purpose |
|---|---|
| **Breadth-First Search (BFS)** | Finds the shortest step count and the related path |
| **Depth-First Search (DFS)** | Shows all available paths along with their path costs (time in months) |
| **A\* Search** | Finds the shortest and most optimal path based on path cost (time) |

## Project Structure
```
BSc-IT-AI-Guidance-System/
└── Project/
    ├── Bsc IT.pl      # Main Prolog program (search logic + console/GUI handling)
    └── index.html     # Web-based GUI interface
```

## Requirements
- [SWI-Prolog](https://www.swi-prolog.org/) installed
- A modern web browser (for GUI mode)

## How to Run

1. **Download/extract** the project files to a location of your choice. Make sure the folder contains both `Bsc IT.pl` and `index.html`.

2. **Open SWI-Prolog** and set the working directory to the extracted folder:
   ```prolog
   cd('/path/to/your/extracted/folder').
   ```
   Example:
   ```prolog
   cd('D:/COU4303_19').
   ```

3. **Consult the program file** in Prolog:
   ```
   File -> Consult -> Bsc IT.pl
   ```

4. Once loaded, start the program by typing:
   ```prolog
   start.
   ```

5. Choose your interface mode by typing `console` (or `c`) or `gui` (or `g`).
   > ⚠️ Do not type a trailing dot for any of these choices (e.g. type `console`, not `console.`).

### Console Mode
1. Enter your A/L status: `pass` or `fail` (this becomes your starting point).
2. Select your dream job by entering the number or the full profession name.
3. Choose a search algorithm: `dfs`, `bfs`, or `a_star`.
4. View your generated career path and estimated timeline.
5. Type `yes` to search again, or `no` to exit.

### GUI Mode
1. When prompted, start a local server on port `8000` or `8001`.
2. Open your browser and navigate to:
   ```
   http://localhost:<port you selected>
   ```
3. Use the graphical interface to explore your career path — no further console input needed.

## License
This project is open source and free to use.

---
*Thank you for using the BSc IT AI Guidance System OUSL!*
