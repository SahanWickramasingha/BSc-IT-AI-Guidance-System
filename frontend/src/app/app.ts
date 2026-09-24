import { HttpClient } from '@angular/common/http';
import { Component, inject, OnDestroy, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Subscription } from 'rxjs';

type Status = 'pass' | 'fail';
type Algorithm = 'dfs' | 'bfs' | 'a_star';
type Goal = 'se_job' | 'ce_job' | 'ai_job' | 'ui_job';

interface Route { path: string[]; time?: number; steps?: string[] }
interface SearchResponse { results: Route[] }

@Component({
  selector: 'app-root',
  imports: [FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit, OnDestroy {
  private readonly http = inject(HttpClient);
  private request?: Subscription;
  private countFrame = 0;

  alStatus: Status = 'pass';
  jobGoal: Goal = 'ai_job';
  algorithm: Algorithm = 'a_star';

  readonly goals: { value: Goal; label: string; short: string; color: string }[] = [
    { value: 'se_job', label: 'Software Engineer', short: 'Software', color: 'blue' },
    { value: 'ce_job', label: 'Cybersecurity Engineer', short: 'Cybersecurity', color: 'teal' },
    { value: 'ai_job', label: 'AI Engineer', short: 'AI Engineer', color: 'violet' },
    { value: 'ui_job', label: 'UI/UX Designer', short: 'UI/UX Design', color: 'coral' },
  ];

  readonly results = signal<Route[] | null>(null);
  readonly loading = signal(false);
  readonly error = signal('');
  readonly animatedMonths = signal<number | null>(null);

  ngOnInit(): void { this.search(); }
  ngOnDestroy(): void {
    this.request?.unsubscribe();
    cancelAnimationFrame(this.countFrame);
  }

  get selectedJob(): string {
    return this.goals.find(goal => goal.value === this.jobGoal)?.label ?? '';
  }

  get previewRoute(): Route | null {
    const routes = this.results();
    if (!routes?.length) return null;
    return this.algorithm === 'dfs'
      ? routes.reduce((best, current) => this.routeMonths(current) < this.routeMonths(best) ? current : best)
      : routes[0];
  }

  get totalMonths(): number | null {
    const route = this.previewRoute;
    return route ? this.routeMonths(route) : null;
  }

  get activeBranchPath(): string {
    return {
      se_job: 'M 430 230 C 505 230 505 80 610 80 L 650 80',
      ce_job: 'M 430 230 C 500 230 505 165 610 165 L 650 165',
      ai_job: 'M 430 230 C 500 230 505 290 610 290 L 650 290',
      ui_job: 'M 430 230 C 505 230 505 370 610 370 L 650 370',
    }[this.jobGoal];
  }

  get activeMotionPath(): string {
    return 'M 65 230 L 430 230 ' + this.activeBranchPath.replace(/^M 430 230 /, '');
  }

  get summaryLabel(): string {
    return {
      dfs: 'Fastest among all routes',
      bfs: 'Fewest-step route estimate',
      a_star: 'Shortest-time route estimate',
    }[this.algorithm];
  }

  routeMonths(route: Route): number {
    if (typeof route.time === 'number') return route.time;
    return route.path.reduce((total, step) => {
      const months = step.match(/\((\d+) months\)$/);
      return total + (months ? Number(months[1]) : 0);
    }, 0);
  }

  selectStatus(value: Status): void { this.alStatus = value; this.search(); }
  selectGoal(value: Goal): void { this.jobGoal = value; this.search(); }
  selectAlgorithm(value: Algorithm): void { this.algorithm = value; this.search(); }

  search(): void {
    this.request?.unsubscribe();
    cancelAnimationFrame(this.countFrame);
    this.error.set('');
    this.results.set(null);
    this.animatedMonths.set(null);
    this.loading.set(true);
    this.request = this.http.post<SearchResponse>('/find_path', {
      al_status: this.alStatus,
      job_goal: this.jobGoal,
      algorithm: this.algorithm,
    }).subscribe({
      next: response => {
        this.results.set(response.results);
        this.loading.set(false);
        if (this.totalMonths !== null) this.animateMonths(this.totalMonths);
      },
      error: () => {
        this.error.set('Could not load your route. Make sure the Flask server is running and try again.');
        this.loading.set(false);
      },
    });
  }

  private animateMonths(target: number): void {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      this.animatedMonths.set(target);
      return;
    }
    const started = performance.now();
    const tick = (now: number): void => {
      const progress = Math.min((now - started) / 950, 1);
      this.animatedMonths.set(Math.round(target * (1 - Math.pow(1 - progress, 3))));
      if (progress < 1) this.countFrame = requestAnimationFrame(tick);
    };
    this.countFrame = requestAnimationFrame(tick);
  }
}
