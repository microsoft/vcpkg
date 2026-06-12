# Evaluate New Port Report Template

```markdown
# Port Audit Report — `{port-name}`

## Declared Metadata

- **License metadata:** `{top-level-and-feature-license-summary-from-vcpkg-json}`
- **Homepage:** `{homepage}`
- **Supports:** `{supports-expression or "not specified"}`
- **Dependencies:** `{high-level summary}`
- **Features:** `{high-level summary}`

## Build Invocation Summary

- **Primary build helper(s):** `...`
- **Key options:** `...`
- **Feature controls:** `...`
- **Platform guards:** `...`

## Install Result

- **Command:** `vcpkg install {port-name}`
- **Outcome:** `...`
- **Notes:** `...`

## Vendored Dependencies

- `None found`

or

- **Bundled component:** `...`
  - **Evidence:** `buildtrees/{port-name}/src/...`
  - **Status:** `installed` / `present but not installed` / `unclear`
  - **Assessment:** `...`

## Optional Dependency Risks

- `None found`

or

- **Dependency / feature:** `...`
  - **Evidence:** `...`
  - **Why it is risky:** `...`
  - **Suggested packaging change:** `...`

## License / Installed Content Findings

- `None found`

or

- **Finding:** `...`
  - **Declared license metadata:** `...`
  - **Observed installed content:** `packages/{port-name}_{target-triplet}/...`
  - **Evidence:** `...`
  - **Assessment:** `...`

## Other Port Review Suggestions

- `None found`

or

- **Suggestion:** `...`
  - **Evidence:** `ports/{port-name}/portfile.cmake` / `ports/{port-name}/vcpkg.json` / installed files
  - **Rationale:** `...`

## Recommended Follow-ups

1. `...`
2. `...`
```
