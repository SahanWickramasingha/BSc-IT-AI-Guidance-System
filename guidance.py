"""Career graph and search algorithms; no Prolog runtime required."""

import heapq
import json
from collections import deque
from pathlib import Path


GRAPH = json.loads(Path(__file__).with_name("career_paths.json").read_text(encoding="utf-8"))
ADJACENCY = {}
for start, end, description, months in GRAPH:
    ADJACENCY.setdefault(start, []).append((end, description, months))

STARTS = {"pass": "al_pass", "fail": "al_fail"}
GOALS = {"se_job", "ce_job", "ai_job", "ui_job"}
ALGORITHMS = {"dfs", "bfs", "a_star"}


def describe(nodes):
    """Return the descriptions for a sequence of adjacent nodes."""
    descriptions = []
    for source, target in zip(nodes, nodes[1:]):
        _, description, months = next(edge for edge in ADJACENCY[source] if edge[0] == target)
        descriptions.append(f"{description} ({months} months)")
    return descriptions


def all_paths(start, goal):
    """Enumerate every simple path in the original edge order (DFS)."""
    def walk(current, visited, total):
        if current == goal:
            yield {"path": describe(visited), "time": total}
            return
        for neighbor, _, months in ADJACENCY.get(current, ()):
            if neighbor not in visited:
                yield from walk(neighbor, (*visited, neighbor), total + months)

    return list(walk(start, (start,), 0))


def shortest_steps(start, goal):
    """BFS: the first path with the fewest edges, using original edge order."""
    queue = deque([(start,)])
    while queue:
        nodes = queue.popleft()
        if nodes[-1] == goal:
            return [{"path": describe(nodes), "steps": list(nodes)}]
        for neighbor, _, _ in ADJACENCY.get(nodes[-1], ()):
            if neighbor not in nodes:
                queue.append((*nodes, neighbor))
    return []


def shortest_time(start, goal):
    """A* with the original zero heuristic (equivalent to uniform-cost search)."""
    frontier = [(0, 0, (start,))]
    best = {}
    order = 0
    while frontier:
        months, _, nodes = heapq.heappop(frontier)
        current = nodes[-1]
        if months > best.get(current, float("inf")):
            continue
        if current == goal:
            return [{"path": describe(nodes), "steps": list(nodes), "time": months}]
        for neighbor, _, duration in ADJACENCY.get(current, ()):
            if neighbor in nodes:
                continue
            new_time = months + duration
            if new_time < best.get(neighbor, float("inf")):
                best[neighbor] = new_time
                order += 1
                heapq.heappush(frontier, (new_time, order, (*nodes, neighbor)))
    return []


def find_paths(al_status, job_goal, algorithm):
    start = STARTS[al_status]
    if algorithm == "dfs":
        return all_paths(start, job_goal)
    if algorithm == "bfs":
        return shortest_steps(start, job_goal)
    return shortest_time(start, job_goal)
