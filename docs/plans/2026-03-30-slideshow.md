# Slideshow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a self-contained Reveal.js HTML slideshow presenting claude-good-boy to a management audience in ~5 minutes across 8 slides.

**Architecture:** Single `docs/slideshow/index.html` file. Reveal.js loaded from CDN. All slide content, custom CSS, and initialization JS embedded inline. No build step, no dependencies to install — open in any browser.

**Tech Stack:** Reveal.js 5.x (CDN), HTML5, embedded CSS, vanilla JS init.

---

### Task 1: Create base HTML with Reveal.js boilerplate and title slide

**Files:**
- Create: `docs/slideshow/index.html`

**Step 1: Create the file with Reveal.js shell and title slide**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>claude-good-boy</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/dist/reveal.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/dist/theme/black.css" />
  <style>
    :root {
      --accent: #f97316;
    }
    .reveal h1, .reveal h2 { color: #ffffff; }
    .reveal h1 { font-size: 2rem; }
    .reveal h2 { font-size: 1.5rem; border-bottom: 2px solid var(--accent); padding-bottom: 0.3em; margin-bottom: 0.6em; }
    .reveal p, .reveal li { font-size: 1rem; line-height: 1.6; color: #d1d5db; }
    .reveal .accent { color: var(--accent); font-weight: bold; }
    .reveal .subtitle { color: #9ca3af; font-size: 1rem; margin-top: 0.5em; }
    .grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1em; margin-top: 1em; }
    .card { background: #1f2937; border: 1px solid #374151; border-radius: 8px; padding: 1em; text-align: center; }
    .card .label { font-size: 0.85rem; color: var(--accent); font-weight: bold; margin-bottom: 0.3em; }
    .card .desc { font-size: 0.75rem; color: #9ca3af; }
    .step-row { display: flex; align-items: center; gap: 1em; margin: 0.6em 0; }
    .step-num { background: var(--accent); color: white; border-radius: 50%; width: 2em; height: 2em; display: flex; align-items: center; justify-content: center; font-weight: bold; flex-shrink: 0; }
    .guardrail { background: #1f2937; border-left: 4px solid var(--accent); padding: 0.8em 1em; border-radius: 0 6px 6px 0; margin: 0.5em 0; }
    .guardrail strong { color: #ffffff; }
    .guardrail span { color: #9ca3af; font-size: 0.85rem; }
    code.install { background: #111827; color: #34d399; padding: 0.8em 1.2em; border-radius: 6px; font-size: 0.85rem; display: block; margin: 1em 0; }
  </style>
</head>
<body>
<div class="reveal">
  <div class="slides">

    <!-- Slide 1: Title -->
    <section>
      <h1>claude-good-boy</h1>
      <p class="subtitle">AI that follows your rules — consistently, across your whole team.</p>
    </section>

  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/dist/reveal.js"></script>
<script>
  Reveal.initialize({ hash: true, transition: 'fade', controls: true, progress: true });
</script>
</body>
</html>
```

**Step 2: Open in browser and verify**

Open `docs/slideshow/index.html` in a browser.
Expected: Title slide renders with black background, orange accent, Reveal.js controls visible.

**Step 3: Commit**

```bash
git add docs/slideshow/index.html
git commit -m "feat(slideshow): add reveal.js shell and title slide"
```

---

### Task 2: Add slides 2, 3, 4 — Problem, Cost, Solution

**Files:**
- Modify: `docs/slideshow/index.html`

**Step 1: Add the three slides inside `<div class="slides">` after the title slide**

```html
    <!-- Slide 2: The Problem -->
    <section>
      <h2>The Problem</h2>
      <p>Your team uses Claude Code — Anthropic's AI coding assistant. Powerful. But out of the box, every developer gets a different experience.</p>
      <ul>
        <li>One developer's AI respects Git conventions. Another's doesn't.</li>
        <li>No shared guardrails on what the AI can or can't do.</li>
        <li>No consistency in how the AI handles sensitive operations.</li>
      </ul>
    </section>

    <!-- Slide 3: The Cost -->
    <section>
      <h2>The Cost</h2>
      <p>Basic AI without config or setup is <span class="accent">unguided</span>.</p>
      <ul>
        <li>Extra code review burden — you can't predict what the AI will do.</li>
        <li>Security risks — the AI may touch things it shouldn't without asking.</li>
        <li>Every developer is working with a different version of the same tool.</li>
      </ul>
    </section>

    <!-- Slide 4: The Solution -->
    <section>
      <h2>The Solution</h2>
      <p><span class="accent">claude-good-boy</span> is a shared set of rules that governs how Claude Code behaves — what it does, how it asks, and what it never touches.</p>
      <ul>
        <li>Installed in <strong>one command</strong> per developer.</li>
        <li><strong>Auto-updates</strong> on every session — no maintenance.</li>
        <li>Works across <strong>all projects</strong> automatically.</li>
      </ul>
    </section>
```

**Step 2: Verify in browser**

Navigate slides 2–4 with arrow keys.
Expected: All three slides render cleanly, bullet points readable, accent color on key terms.

**Step 3: Commit**

```bash
git add docs/slideshow/index.html
git commit -m "feat(slideshow): add problem, cost, and solution slides"
```

---

### Task 3: Add slides 5 and 6 — How it Works, What's Covered

**Files:**
- Modify: `docs/slideshow/index.html`

**Step 1: Add after slide 4**

```html
    <!-- Slide 5: How it Works -->
    <section>
      <h2>How it Works</h2>
      <div class="step-row">
        <div class="step-num">1</div>
        <p><strong>Install once</strong> — one curl command clones the rules to the developer's machine.</p>
      </div>
      <div class="step-row">
        <div class="step-num">2</div>
        <p><strong>Rules load automatically</strong> — Claude Code discovers and applies them at session start.</p>
      </div>
      <div class="step-row">
        <div class="step-num">3</div>
        <p><strong>Always up to date</strong> — a background hook pulls the latest rules on every session.</p>
      </div>
    </section>

    <!-- Slide 6: What's Covered -->
    <section>
      <h2>What's Covered</h2>
      <div class="grid">
        <div class="card">
          <div class="label">Git</div>
          <div class="desc">Commit conventions, branch naming, no force-push</div>
        </div>
        <div class="card">
          <div class="label">Java + Spring Boot</div>
          <div class="desc">Architecture, Lombok, JPA patterns</div>
        </div>
        <div class="card">
          <div class="label">Angular</div>
          <div class="desc">Signals, OnPush, loading states</div>
        </div>
        <div class="card">
          <div class="label">npm</div>
          <div class="desc">Dependency gate, lockfile rules</div>
        </div>
        <div class="card">
          <div class="label">Maven</div>
          <div class="desc">BOM, plugin versions, SNAPSHOT policy</div>
        </div>
        <div class="card">
          <div class="label">Jenkins</div>
          <div class="desc">CLI usage and job conventions</div>
        </div>
      </div>
    </section>
```

**Step 2: Verify in browser**

Expected: Step-by-step layout on slide 5 is readable. Slide 6 shows a 3×2 grid of cards with orange labels.

**Step 3: Commit**

```bash
git add docs/slideshow/index.html
git commit -m "feat(slideshow): add how-it-works and coverage slides"
```

---

### Task 4: Add slides 7 and 8 — Key Guardrails, Get Started

**Files:**
- Modify: `docs/slideshow/index.html`

**Step 1: Add after slide 6**

```html
    <!-- Slide 7: Key Guardrails -->
    <section>
      <h2>Key Guardrails</h2>
      <p>The rules that directly reduce risk:</p>
      <div class="guardrail">
        <strong>Dependencies</strong><br/>
        <span>Never adds, removes, or changes a dependency without asking first.</span>
      </div>
      <div class="guardrail">
        <strong>Git history</strong><br/>
        <span>Never force-pushes. Uses git revert to undo changes safely.</span>
      </div>
      <div class="guardrail">
        <strong>Secrets</strong><br/>
        <span>Never commits API keys, passwords, or tokens to version control.</span>
      </div>
    </section>

    <!-- Slide 8: Get Started -->
    <section>
      <h2>Get Started</h2>
      <p>One command installs everything:</p>
      <code class="install">bash &lt;(curl -s https://raw.githubusercontent.com/vado-consulting/claude-good-boy/main/setup.sh)</code>
      <p style="margin-top: 1em;">That's it. Claude Code sessions are governed from that moment on.</p>
      <p style="margin-top: 1.5em; color: #6b7280; font-size: 0.85rem;">github.com/vado-consulting/claude-good-boy</p>
    </section>
```

**Step 2: Verify in browser**

Navigate to slides 7 and 8.
Expected: Guardrail cards with orange left border. Get started slide shows the install command in green monospace on dark background.

**Step 3: Commit**

```bash
git add docs/slideshow/index.html
git commit -m "feat(slideshow): add guardrails and get-started slides"
```

---

### Task 5: Final polish and push

**Files:**
- Modify: `docs/slideshow/index.html`

**Step 1: Full walkthrough check**

Open in browser. Go through all 8 slides with arrow keys. Check:
- [ ] All slides readable without scrolling
- [ ] Accent color consistent throughout
- [ ] No layout overflow or clipped text
- [ ] Install command on slide 8 is selectable/copyable

**Step 2: If any text overflows, reduce font size in `:root` style**

Add to the `<style>` block if needed:
```css
.reveal ul { margin-top: 0.5em; }
.reveal li { margin-bottom: 0.3em; }
```

**Step 3: Commit and push**

```bash
git add docs/slideshow/index.html
git commit -m "fix(slideshow): polish layout and spacing"
git push origin master
```
