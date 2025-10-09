---
description: Prompt to create a feature SPECIFICATION (`spec.md`) document
mode: agent
---

**BEGIN**

Follow the instructions below to create a feature SPECIFICATION document.

1. READ EXISTING REQUIREMENTS: Run the requirements script:

```sh
.devspecs/scripts/read-requirements.bash
```

2. Ask the user which of the listed requirements does this spec refer to.

3. INITIALIZE: Run the spec initialization script:

```sh
export REQUIREMENT_TITLE="% save requirement title selected by the user in the previous step in this variable %"
.devspecs/scripts/spec-init.bash "${REQUIREMENT_TITLE}"
```

4. Use the output information from the script above to complete the next steps.

5. Identify the spec_dir location of the `spec.md` file to use. That file contains a template where sections to be replaced are marked by percent sign delimiters (as in: % TEXT %). You must fill the information for the PLAN into the `plan.md` file following the template format. Update the `plan.md` file as you proceed through the next steps. TEMPLATE RULE: follow the guidance between percent sign delimiters: example: % GUIDANCE %; remove all text between and including those delimiters, replacing it with the resulting text if there is any.

**Document section requirements**:

- Mandatory sections must be completed for every feature.
- Optional sections include only when relevant to the feature.
- When a section doesn't apply, remove it entirely (don't leave as "N/A").

6. Extract the User Story and Acceptance Criteria as previously read from the requirements document and fill these in the template.

7. Based on the user story and acceptance criteria, identify any Edge Cases.

8. Based on the user story, if data is involved, identify Key Entities.

9. Based on the user story, if the UI is involved, identify UI Components.

10. Run review checklist (go to **CHECK**).

11. STOP.

---

**CHECK**

Content Requisites:

- [ ] Ensure there are no implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

Requirement Completeness:

- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions are identified
