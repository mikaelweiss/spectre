# Spectre

Spec-driven development for Claude Code.

Write specs. Implement them. Verify them with AI reasoning.

## Installation

```
/plugin install spectre
```

## Commands

### `/spec-init [area]`
Bootstrap Spectre for an existing codebase. Analyzes your project thoroughly and creates specs documenting current functionality. Optionally focus on a specific area (e.g., `auth`).

### `/spec-create`
Create a new spec through guided ideation. Spectre asks clarifying questions, then writes a complete spec with all the context needed for implementation.

### `/spec-implement [spec-name]`
Implement a spec. Reads the spec, makes the changes, runs tests, loops until passing.

### `/spec-test [spec-name]`
Verify specs are satisfied using AI reasoning against the VERIFY criteria.

## Spec Format

Specs live in `specs/` as markdown files. Each file can contain multiple related specs.

```
═══════════════════════════════════════════════════════════════
AUTH SPECS
═══════════════════════════════════════════════════════════════
  ✅ Sign in button styling          Jan 15
  🔄 Failed login shows error        Jan 14
  ❌ Session timeout behavior        Jan 13
  ⏸  Password reset flow             not run
═══════════════════════════════════════════════════════════════
```

### Status Icons

| Icon | Meaning |
|------|---------|
| ✅ | Passed, files unchanged |
| 🔄 | Passed, but files changed since (stale) |
| ❌ | Failed — stays until re-tested and passes |
| ⏸ | Never tested |

## How It Works

1. **Init** — `/spec-init` analyzes an existing codebase and creates specs for current functionality
2. **Create** — `/spec-create` walks you through ideation, asks questions, writes a complete spec
3. **Implement** — `/spec-implement` reads the spec and implements it exactly as specified
4. **Test** — The implement agent calls the test agent, loops until specs pass
5. **Track** — Hooks automatically detect file changes and mark specs as stale

## File Structure

```
your-project/
├── specs/
│   ├── auth.md
│   ├── navigation.md
│   └── .spectre-state.json
└── ...
```

## License

MIT
