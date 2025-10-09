---
description: Prompt to create a TASKS LIST (`tasks.md`) document
mode: agent
---

**BEGIN**

Follow the instructions below to create an TASKS LIST document for the current feature.

1. INITIALIZE: Run the tasks initialization script:

```sh
.devspecs/scripts/tasks-init.bash
```

2. Use the output information from the script above to complete the next steps.

3. Identify the spec_dir location of the `tasks.md` file to use. That file contains a template where sections to be replaced are marked by percent sign delimiters (as in: % TEXT %). You must fill the information for the TASKS LIST into the `tasks.md` file following the template format. Update the `tasks.md` file as you proceed through the next steps. TEMPLATE RULE: follow the guidance between percent sign delimiters: example: % GUIDANCE %; remove all text between and including those delimiters, replacing it with the resulting text if there is any.

4. Read the `spec.md` file for the feature. If not found: output ERROR "No feature spec at {path}".

5. Read the `plan.md` file for the feature. If not found: output ERROR "No implementation plan at {path}".

6. Read other files: `research.md`, `contracts/`, `data-model.md`, if they exist.

7. Generate tasks using the following strategies:

**Task Generation Rules:**

- From Contracts:

  - Each contract file → contract test task **[P]**
  - Each endpoint → implementation task

- From Data Model:

  - Each entity → model creation task **[P]**
  - Relationships → service layer tasks

- From User Stories:

  - Each story → integration test **[P]**

- Ordering:

  - Setup → Tests → Models → Services → Endpoints → Polish
  - Dependencies block parallel execution

**Task Generation Strategy**:

- For each contract, create a contract test task
- For each entity, create a model creation task
- For each user story, create an integration test task
- Create implementation tasks to make tests pass

**Ordering Strategy**:

- TDD order: Tests before implementation
- Dependency order: Models before services before UI
- Mark **[P]** for tasks that can be parallel
- Number tasks sequentially
- Generate a dependency graph

**Estimated Output**: 25-30 numbered, ordered tasks in `tasks.md`

8. Run review checklist (go to **CHECK**).

9. STOP.

---

**CHECK**

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks are truly independent
- [ ] No task modifies same file as another **[P]** task
