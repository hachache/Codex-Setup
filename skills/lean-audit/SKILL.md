---
name: lean-audit
description: Audit a whole repository for removable complexity and dependency bloat. Use when the user asks for a repo-wide lean audit, over-engineering audit, bloat audit, deletion audit, "what can this repo delete", "make it less overkill", "review the architecture for YAGNI", or "$lean-audit". This skill reports ranked findings only and does not apply fixes.
---

# Lean Audit

Audit the repository for complexity that can be deleted or replaced with existing code, standard libraries, native platform features, or simpler direct implementations. This is broader than `lean-review`: scan the tree, not only the diff.

## Workflow

1. Map the repo shape with `rg --files`, skipping generated output, vendored code, lockfiles, build artifacts, `.git`, and dependency folders.
2. Search for likely bloat: wrappers, one-use abstractions, duplicated helpers, dependency adapters, dead config, unused flags, custom parsers, custom caches, custom validators, framework shims.
3. Verify each finding against call sites before reporting it.
4. Rank findings by deletion value and confidence.
5. Report only. Do not patch unless the user asks for implementation.

## Hunt List

- Single-implementation interfaces, factories, strategies, registries, providers, or repositories.
- Helpers that duplicate stdlib, framework, native platform, DB, shell, or IaC module behavior.
- Dependencies used for one trivial operation.
- Config values nobody sets and feature flags nobody reads.
- Layers that only delegate.
- Repeated guards that belong once at the shared boundary.
- Scripts, docs, or modules made obsolete by current workflow.

## Output

Rank biggest safe reduction first:

```text
<rank>. <tag>: <what to cut>. <replacement>. [path]
```

Tags: `delete`, `reuse`, `stdlib`, `native`, `dependency`, `yagni`, `shrink`.

End with:

```text
net: -<N> lines possible, -<M> deps possible, <K> follow-ups.
```

If there is nothing material:

```text
Lean already. Ship.
```

## Boundaries

Scope is over-engineering only. Correctness, security, performance, and production safety findings belong in normal review or `loop critical`. Do not recommend deleting tests, probes, RBAC, secrets handling, validation, migrations, rollback paths, or accessibility support merely because they add lines.
