---
name: lean-debt
description: Harvest `lean:` and `ponytail:` shortcut comments into a debt ledger. Use when the user asks for lean debt, shortcut ledger, deferred simplifications, "what shortcuts did we take", "list lean markers", "ponytail debt", or "$lean-debt". This skill reads and reports by default, and writes a ledger only when explicitly requested.
---

# Lean Debt

Collect deliberate simplification markers so shortcuts stay visible and revisit triggers do not rot.

## Marker Convention

Prefer `lean:` for new work:

```text
lean: <simplification>; ceiling: <known limit>; revisit when <trigger>
```

Accept `ponytail:` markers for compatibility with imported work.

Good marker:

```python
# lean: linear scan keeps this script dependency-free; ceiling: <1000 rows; revisit when input grows or runtime exceeds 1s
```

Bad marker:

```python
# lean: fix later
```

## Workflow

1. Search comment markers only, skipping `.git`, dependencies, build output, generated files, and lockfiles.
2. Use `rg -n "(#|//|/\\*|<!--|;|--|%)\\s*(lean|ponytail):"`.
3. For each marker, extract file, line, simplification, ceiling, and revisit trigger.
4. Flag markers without a concrete ceiling or trigger as `no-trigger`.
5. Report only unless the user explicitly asks to write a ledger file.

## Output

Group by file:

```text
path:L<line>: <marker>. ceiling: <limit>. revisit: <trigger>. status: ok|no-trigger
```

End with:

```text
markers: <N>, no-trigger: <M>
```

If no markers exist:

```text
No lean debt. Clean ledger.
```

## Optional Ledger Write

Only when asked to persist, write `LEAN-DEBT.md` with the same rows plus date, command used, and unresolved `no-trigger` count.
