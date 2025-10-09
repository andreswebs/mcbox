---
description: Prompt to create a feature IMPLEMENTATION PLAN (`plan.md`) document and adjacent documents (`research.md`, `contracts/`, `data-model.md`)
mode: agent
---

**BEGIN**

Follow the instructions below to create an IMPLEMENTATION PLAN and adjacent documents for the current feature.

1. INITIALIZE: Run the plan initialization script:

```sh
.devspecs/scripts/plan-init.bash
```

2. Use the output information from the script above to complete the next steps.

3. Identify the spec_dir location of the `plan.md` file to use. That file contains a template where sections to be replaced are marked by percent sign delimiters (as in: % TEXT %). You must fill the information for the PLAN into the `plan.md` file following the template format. Update the `plan.md` file as you proceed through the next steps. TEMPLATE RULE: follow the guidance between percent sign delimiters: example: % GUIDANCE %; remove all text between and including those delimiters, replacing it with the resulting text if there is any.

4. Read the `spec.md` file for the feature. If not found: output ERROR "No feature spec at {path}". Scan for (NEEDS CLARIFICATION).

5. RESEARCH: Using relevant tools available to you, execute RESEARCH to resolve any (NEEDS CLARIFICATION) items. Save the results in a file named `research.md` at the spec_dir location. If NEEDS CLARIFICATION remain: output ERROR "Couldn't resolve unknowns". Use the following format to consolidate results in the `research.md` document:

```md
## % NAME: give a short name to the researched item %

### Description:

% short contextual description for what NEEDED CLARIFICATION %

### Decision:

% what was chosen %

### Reason:

% why chosen %

### Alternatives considered:

% what else was evaluated %

### Best practices:

% find best practices for {tech} in {domain} using available tools; decide which tool is best for the research %
```

**Output**: `research.md` with all NEEDS CLARIFICATION resolved.

6. DATA MODELING: When relevant, extract data entities' descriptions from feature spec, save results in a file named `data-model.md` at the spec_dir location. Ensure you list:

   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

**Output**: `data-model.md`

7. API CONTRACTS: Generate API contracts from functional requirements, save results to new files in `contracts/` at the spec_dir location. Rules:

   - For each user action, define an API endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

**Output**: `contracts/`

8. CONTRACT TESTING: Define contract tests from contracts. Add descriptions to the `plan.md`. Rules:

   - One test file per endpoint
   - Assert request/response schemas

9. INTEGRATION TESTING: Identify test scenarios from user stories. Add descriptions to the `plan.md`. Rules:

   - For each user story create one integration test scenario.

10. Run review checklist (go to **CHECK**).

11. STOP.

---

**CHECK**

- [ ] Plan file created (`plan.md`)
- [ ] Research completed, or not needed
- [ ] All NEEDS CLARIFICATION resolved
- [ ] Data modeling completed, or not needed
- [ ] API Design completed, or not needed
- [ ] UI Design completed, or not needed
- [ ] Testing plan completed

(go back)
