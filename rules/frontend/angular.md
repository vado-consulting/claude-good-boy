---
paths:
  - "frontend/**/*.ts"
  - "frontend/**/*.html"
  - "frontend/**/*.scss"
  - "*/frontend/**/*.ts"
  - "*/frontend/**/*.html"
  - "*/frontend/**/*.scss"
---

# Frontend Conventions — Angular 19 + PrimeNG

## Component Architecture

- **Standalone components only** — no NgModules
- **OnPush change detection** on every component
- **Lazy loading** all routes via `loadComponent()`
- **Separate `.html` and `.scss` files** — inline `template` only if ≤ 3 lines

```typescript
// Good
@Component({
  selector: 'app-user-list',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './user-list.component.html',
  styleUrl: './user-list.component.scss',
  imports: [CommonModule, TableModule, SkeletonModule],
})
export class UserListComponent {}
```

## Reactivity — MANDATORY

- **All state must be signals or observables** — never plain mutable variables
- **Prefer `| async` pipe** in templates over manual `subscribe()`
- `signal()` for local UI state only (toggles, form values)
- `computed()` for derived state from signals
- `subscribe()` only for side effects — always `takeUntilDestroyed()` in constructor
- `toSignal()` only when combining multiple streams into computed state
- Services expose **observables**, never plain properties

```typescript
// Good — async pipe manages subscription
users$ = this.userService.getUsers();

// Good — signal for local UI state
isMenuOpen = signal(false);

// Bad — plain variable for async data
users: User[] = [];
ngOnInit() { this.userService.getUsers().subscribe(u => this.users = u); }
```

## Templates

- **No method calls in templates** — use `computed()`, pipes, or inline expressions
- **Const lookup maps** instead of switch/if-else chains

```html
<!-- Good -->
@if (users$ | async; as users) {
  <p-table [value]="users">...</p-table>
} @else {
  <p-skeleton height="2rem" />
}

<!-- Bad — method call in template re-runs on every change detection -->
<p>{{ formatUser(user) }}</p>
```

## Loading States — MANDATORY

Every async data load must show a skeleton while pending. Never show blank space.

```html
@if (data$ | async; as data) {
  <!-- real content -->
} @else {
  <p-skeleton height="1.5rem" styleClass="mb-2" />
  <p-skeleton height="1.5rem" styleClass="mb-2" />
  <p-skeleton height="1.5rem" />
}
```

## Models

- One interface per file in `core/models/`, named `<entity>.model.ts`
- Import from specific file, not barrel exports

## Styling

- **Tailwind CSS** for layout, spacing, flexbox
- **PrimeNG** for interactive components (buttons, tables, toggles, drawers, skeletons)
- **SCSS** for component-specific styles
