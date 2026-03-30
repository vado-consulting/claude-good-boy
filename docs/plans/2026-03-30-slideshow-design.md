# Slideshow Design — claude-good-boy

**Date:** 2026-03-30
**Audience:** Management / non-technical stakeholders
**Format:** Self-contained HTML using Reveal.js (CDN)
**Duration:** ~5 minutes, 8 slides

---

## Goal

Present the what and why of claude-good-boy to a non-technical management audience. Focus on business value: consistency, risk reduction, and zero-maintenance governance of AI coding behavior — not implementation details.

---

## Slide Structure

| # | Title | Purpose |
|---|-------|---------|
| 1 | claude-good-boy — AI that follows your rules | Hook + framing |
| 2 | The Problem | Ungoverned AI = inconsistent behavior across developers |
| 3 | The Cost | Unguided AI adds review overhead and security risk |
| 4 | The Solution | Shared rules, one install, applied automatically |
| 5 | How it Works | Three-step visual: Install → Rules load → Session applies them |
| 6 | What's Covered | Grid of rule sets with one-line guardrail summaries |
| 7 | Key Guardrails | Three management-relevant wins: deps, force-push, secrets |
| 8 | Get Started | One curl command + repo link |

---

## Tone & Style

- Plain language — no technical jargon
- Confident, not salesy
- Framing: AI is powerful but needs structure, just like any team member
- Avoid: "AI can't be trusted" → use "basic AI without config or setup is unguided"

---

## Technical Decisions

- **Reveal.js via CDN** — polished look, keyboard/click navigation
- Single `docs/slideshow/index.html` file — self-contained, shareable by email or browser
- Dark theme (Reveal.js `moon` or `black`) for presentation contrast
- No speaker notes needed for this version

---

## Output

`docs/slideshow/index.html` — committed to the repo.
