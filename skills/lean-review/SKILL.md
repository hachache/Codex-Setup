---
name: lean-review
description: Review the current diff for removable complexity only. Use when the user asks for a lean review, over-engineering review, simplification review, bloat review, "what can we delete", "is this overkill", "review like Ponytail", or "$lean-review". This skill reports findings only and does not apply fixes.
---

# Lean Review

Review changed code for unnecessary complexity. Focus only on what can be deleted, reused, replaced by stdlib/native features, or shortened. Do not review correctness, security, performance, formatting, or style unless the issue is directly caused by over-engineering.

## Workflow

1. Inspect the current diff and the touched local patterns.
2. Identify the smallest correct replacement for each overbuilt part.
3. Prefer deletion over rewriting.
4. Keep safety checks, trust-boundary validation, accessibility basics, data-loss handling, and requested behavior.
5. Report only. Do not patch unless the user asks for fixes.

## Tags

- `delete`: dead code, speculative feature, unused option, unused branch, redundant wrapper.
- `reuse`: local helper, component, role, script, module, pattern, or config already exists.
- `stdlib`: hand-rolled behavior covered by a language standard library.
- `native`: platform feature covers it: browser, CSS, DB, OS, shell, Kubernetes, Terraform, Ansible module, etc.
- `dependency`: new or existing dependency is not earned by the current scope.
- `yagni`: abstraction, interface, factory, plugin point, config, hook, or extension with one real use.
- `shrink`: same behavior with fewer lines and no weaker edge-case handling.

## Output

Lead with findings, one line each:

```text
path:L<line>: <tag>: <what to cut>. <replacement>.
```

End with:

```text
net: -<N> lines possible, -<M> deps possible.
```

If there is nothing meaningful to cut:

```text
Lean already. Ship.
```

## Boundaries

Never flag a minimal targeted test as bloat when it proves non-trivial logic. Never remove validation at trust boundaries, security checks, accessibility affordances, idempotence, rollback paths, or explicit user requirements. If a simplification has a known ceiling, recommend a `lean:` comment with ceiling and revisit trigger.
