# Test Spec

Verify specs are satisfied using AI reasoning.

## Input
Spec name: $ARGUMENTS

---

Use the **spec-tester** agent to verify the spec.

The agent will:
1. Find the spec in `specs/` (by name or partial match)
2. Read the VERIFY section
3. Read the referenced files
4. Reason about whether each VERIFY item is satisfied
5. Return pass/fail with explanation
6. Update the spec header with result (✅ or ❌) and current date
7. Update `.spectre-state.json` with file hashes

If no spec name provided:
- If a spec file name is given (e.g., "auth"), test all specs in that file
- Otherwise, list available specs and ask which to test

Launch the spec-tester agent now.
