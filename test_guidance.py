"""Run with python -m unittest discover."""

import unittest

from guidance import GOALS, STARTS, find_paths


class SearchTests(unittest.TestCase):
    def test_each_route_has_valid_results(self):
        for status in STARTS:
            for goal in GOALS:
                with self.subTest(status=status, goal=goal):
                    dfs = find_paths(status, goal, "dfs")
                    bfs = find_paths(status, goal, "bfs")
                    optimal = find_paths(status, goal, "a_star")
                    self.assertEqual(len(dfs), 4)
                    self.assertEqual(len(bfs), 1)
                    self.assertEqual(len(optimal), 1)
                    self.assertEqual(optimal[0]["time"], min(result["time"] for result in dfs))
                    self.assertEqual(len(bfs[0]["path"]), min(len(result["path"]) for result in dfs))
                    self.assertEqual(bfs[0]["steps"][0], STARTS[status])
                    self.assertEqual(optimal[0]["steps"][-1], goal)

    def test_original_software_engineer_timings(self):
        results = find_paths("pass", "se_job", "dfs")
        self.assertEqual([result["time"] for result in results], [54, 44, 54, 47])
        self.assertEqual(find_paths("fail", "se_job", "a_star")[0]["time"], 68)


if __name__ == "__main__":
    unittest.main()
