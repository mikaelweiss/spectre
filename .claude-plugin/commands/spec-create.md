# Create Spec

Create a new spec through guided ideation.

## Input
$ARGUMENTS

---

Use the **spec-creator** agent to run the ideation flow.

The agent will:
1. Do a quick skim of the codebase to understand context
2. Ask 3-5 clarifying questions at a time
3. Gather all information needed for implementation
4. Write a complete spec to `specs/`

If the user provided arguments, use them as the starting context for what they want to build.

Launch the spec-creator agent now.
