---
name: cv-site-from-sources
description: Build or revise factual portfolio/CV/resume websites from source documents and assets. Use when Codex is asked to create, polish, translate, factualize, enrich, visually QA, or publish a personal CV site using PDFs, uploaded CVs, photos, LinkedIn/company references, logos, or existing repo content, especially when the user wants less AI-style copy and source-backed professional presentation.
---

# Cv Site From Sources

## Objective

Produce a polished CV site whose claims are traceable to source material, whose visual choices serve the candidate, and whose behavior has been checked in a browser before handoff.

## Workflow

1. Establish sources
   - Identify all provided source files: CV PDF, prompt brief, photos, logos, existing repo content, public profile links.
   - Extract text from PDFs with available local tools. If OCR is needed, state that before relying on low-quality extraction.
   - Build a short fact register: name, title, location, companies, dates, roles, achievements, languages, links, visual assets.
   - Mark every important claim as `source-backed`, `inferred`, or `missing`.

2. Remove unsupported copy
   - Replace generic marketing language with precise facts from the register.
   - Do not invent metrics, awards, tools, seniority, employers, schools, dates, or links.
   - If the user asks for richer content but sources are thin, write restrained role summaries and keep them visibly factual.
   - Preserve the project language unless the user asks for translation. For bilingual sites, choose one default language and keep translations structurally aligned.

3. Integrate assets
   - Prefer real provided images/logos over decorative placeholders.
   - For company logos, use repository assets first. If fetching current public assets, verify source and licensing risk; do not hotlink fragile URLs unless the project already does that.
   - Keep alt text factual: person name, company logo, or link purpose.
   - Avoid visual clutter that weakens the CV purpose.

4. Design and implementation pass
   - Read the existing code and design system before editing.
   - Keep the first viewport anchored on the person: name, current positioning, key proof, primary action or link.
   - Use typography, spacing, and motion to improve scanning. Avoid oversized hero treatment that hides the CV content.
   - Use subtle motion only when it stays smooth and does not cause scroll jumps or layout instability.
   - Keep edits scoped to the CV site and existing framework.

5. QA loop
   - Run the project checks available in the repo: typecheck, lint, tests, build.
   - Start the dev server when needed and inspect the site in the browser.
   - Check desktop and mobile breakpoints for horizontal overflow, overlapping text, missing assets, broken links, scroll jumps, and cache-related failures.
   - Verify language switchers, LinkedIn/external links, image rendering, and route refresh behavior.
   - Fix failures before handoff unless blocked by missing source material.

6. Git and publish
   - Create a branch before broad redesigns when the user asks or the repo workflow implies it.
   - Keep one logical change per commit using Conventional Commits.
   - Before push, report exact checks run and any remaining unverified areas.
   - Do not force-push or merge unless the user explicitly asked.

## Output Contract

When finishing, include:
- created/changed files;
- source facts used and any important missing facts;
- verification commands and browser checks;
- repo/branch/push status if Git was involved.

## Stop Conditions

Stop and ask for the missing source when a requested claim would require inventing credentials, dates, employers, private contact data, or sensitive personal details.
