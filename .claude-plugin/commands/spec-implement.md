# Implement Spec

Implement a spec and verify it passes.

## Input
Spec name: $ARGUMENTS

---

Use the **spec-implementer** agent to implement the spec.

The agent will:
1. Find the spec in `specs/` (by name or partial match)
2. Read the spec completely
3. Follow the IMPLEMENTATION ORDER exactly
4. Make changes as specified in CHANGES REQUIRED
5. Use DOCUMENTATION for API reference
6. Call the spec-tester agent to verify
7. If tests fail, fix and re-test until passing
8. Update the spec header with ✅ and current date

If no spec name provided, list available specs and ask which to implement.

Launch the spec-implementer agent now.
