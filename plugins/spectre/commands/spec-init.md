# Initialize Specs

Bootstrap Spectre for an existing codebase. Analyzes the project and creates initial specs for existing functionality.

## Input
$ARGUMENTS

---

Use the **spec-initializer** agent to analyze the codebase and create specs.

The agent will:
1. Set up the `specs/` directory and `.spectre-state.json`
2. Explore the codebase structure thoroughly
3. Identify major modules, features, and components
4. Create spec files organized by area (auth, navigation, etc.)
5. For each feature, document current behavior as specs

If arguments are provided, focus on that area (e.g., "auth" or "navigation").

Launch the spec-initializer agent now.
