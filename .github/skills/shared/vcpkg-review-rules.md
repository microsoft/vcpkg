# vcpkg PR review rules

A database of review rules for pull requests to [microsoft/vcpkg](https://github.com/microsoft/vcpkg). Each rule has a stable ID, a category, a severity, a scope, a concrete check, and its sources: vcpkg documentation and/or links to reviewer comments on closed microsoft/vcpkg pull requests where maintainers applied the rule.

The rules complement [review-vcpkg-pr-guide.md](review-vcpkg-pr-guide.md). When the guide and a rule disagree, the guide wins. For example, version updates are not blocked by unrelated pre-existing defects.

## Applying the rules

1. Classify the change: new port, port update (new upstream version or packaging fix), version database, CI baseline, scripts/tooling, or helper port. Then select every rule whose **Scope** matches. Rules with scope `all` apply to every port change.
2. Evaluate each selected rule against the evidence the review can obtain. Evidence includes the diff, the complete port directory, upstream sources at the packaged revision, CI logs, and the installed package. Don't treat an unverified rule as passing.
3. Flag each violation with the rule ID, the affected file and line, the evidence, and whether the PR introduced the problem or it already existed.
4. Map violations to verdicts as follows:
   - A **blocking** violation that the PR introduces leads to `request-changes`.
   - A pre-existing **blocking** violation, or any **non-blocking** violation, leads to `approve-with-notes` unless the guide says otherwise.
   - **Advisory** rules are suggestions. Mention them only when they are cheap to fix or clearly helpful.
5. Rule IDs belong in maintainer-facing findings. Contributor-facing feedback describes the problem and links the documentation instead of citing rule IDs.
6. Don't apply a rule to dead branches that are skipped by `if(FALSE)` or similar.

**Severity**

- `blocking`: Maintainers withhold the merge until the problem is fixed.
- `non-blocking`: Maintainers normally request a fix but accept the PR with notes, especially when the problem already existed.
- `advisory`: A suggestion or nit.

**Scope**

- `all`: Every change to a port.
- `new-port`: Ports that the PR adds.
- `port-update`: Changes to existing ports.
- `versions`: Changes under `versions/`.
- `ci-baseline`: Changes to `scripts/ci.baseline.txt` or `scripts/ci.feature.baseline.txt`.
- `scripts`: Changes under `scripts/` other than the two CI baseline files, under `triplets/`, or to tooling.
- `helper-port`: `vcpkg-*` helper (script) ports.

**Sources**

- Documentation links point to [learn.microsoft.com/vcpkg](https://learn.microsoft.com/vcpkg) or to files in this repository.
- `PRs:` links point to the reviewer comments where maintainers applied the rule.
- Rules that list only PR links are established reviewer practice that isn't documented elsewhere.

## Maintaining this database

- IDs have the form `<CATEGORY>-<NNN>` and are never renumbered or reused. Give a new rule the next free number in its category, even if that places it out of order.
- To retire a rule, keep its heading, append `(retired)`, and replace its body with the reason for retirement and the rule that replaces it, if any.
- Back each new rule with documentation or with at least one link to a reviewer comment on a microsoft/vcpkg pull request.

## Categories

| Prefix | Category | Rules |
|---|---|---|
| `PR` | [Pull request scope and process](#pr-pull-request-scope-and-process) | 23 |
| `NEW` | [New port acceptance](#new-new-port-acceptance) | 17 |
| `VER` | [Versioning and version database](#ver-versioning-and-version-database) | 16 |
| `MAN` | [Manifest (vcpkg.json)](#man-manifest-vcpkgjson) | 12 |
| `SRC` | [Source acquisition](#src-source-acquisition) | 12 |
| `PAT` | [Patches](#pat-patches) | 23 |
| `PF` | [Portfile authoring](#pf-portfile-authoring) | 24 |
| `DEP` | [Dependencies and features](#dep-dependencies-and-features) | 30 |
| `BLD` | [Build configuration and build systems](#bld-build-configuration-and-build-systems) | 27 |
| `LAY` | [Installed layout and post-build checks](#lay-installed-layout-and-post-build-checks) | 22 |
| `INT` | [Consumer integration (CMake and pkg-config)](#int-consumer-integration-cmake-and-pkg-config) | 34 |
| `USE` | [Usage text](#use-usage-text) | 8 |
| `LIC` | [License and copyright](#lic-license-and-copyright) | 8 |
| `PLT` | [Platform and triplet support](#plt-platform-and-triplet-support) | 11 |
| `CI` | [CI, baselines, and testing](#ci-ci-baselines-and-testing) | 16 |
| `SCR` | [Scripts, tooling, triplets, and helper ports](#scr-scripts-tooling-triplets-and-helper-ports) | 23 |

Total: 306 rules.

## PR: Pull request scope and process

### PR-001: Get PR checks passing before requesting review

- **Rule:** A PR is reviewable only when its checks, including the Microsoft CLA, pass or the contributor explains a failure as unrelated (for example, it also fails on master) or asks for help. Authors must investigate and fix the failures their change causes; maintainers draft red PRs and treat a red build alone as reason to request changes.
- **Check:** Failing checks or a pending license/cla status on a non-draft PR, whether the same failure occurs on master or in the CI baseline, and maintainer comments such as "Drafting due to build failures."
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Close inactive PRs](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#close-inactive-prs); [Maintainer guide: Use GitHub draft PRs](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#use-github-draft-prs); PRs: [#44653](https://github.com/microsoft/vcpkg/pull/44653#issuecomment-3530389188), [#52689](https://github.com/microsoft/vcpkg/pull/52689#pullrequestreview-4622003238)

### PR-002: Block updates only on regressions the PR introduces

- **Rule:** Classify each finding, including AI-assisted ones, as introduced or pre-existing by checking it against the baseline version. Updates are blocked only by regressions or a package left unusable; pre-existing defects (vendoring, license gaps, broken CMake or pkg-config metadata, failures on unaffected platforms), upstream bugs the port faithfully packages, and modernization of untouched code become non-blocking follow-ups or upstream reports instead of holding the update hostage. New ports meet the full standard.
- **Check:** For each finding, build or inspect the previous port version and upstream release, label the finding "introduced" or "pre-existing" in the review, and request changes only for introduced problems.
- **Severity:** non-blocking · **Scope:** port-update
- **Sources:** PRs: [#54313](https://github.com/microsoft/vcpkg/pull/54313#pullrequestreview-5422293587), [#52864](https://github.com/microsoft/vcpkg/pull/52864#discussion_r3625368016)

### PR-003: Fix or rebut every blocking AI-review finding

- **Rule:** Maintainers post curated AI-assisted findings because they catch problems build-only CI misses, such as uncontrolled dependencies, license gaps, and broken consumers. Contributors must fix each finding marked blocking or identified as a regression or new-port problem, or rebut it with concrete technical evidence; objecting that a bot wrote it resolves nothing. Items labeled pre-existing or "for next time" are optional on updates.
- **Check:** Reviews quoting "AI found", "GPT ... reports", or numbered findings (F1, F2) marked blocking; confirm each has a matching commit or an evidence-based reply before merge.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: AI-identified bugs in new ports](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ai-identified-bugs-in-new-ports); PRs: [#52762](https://github.com/microsoft/vcpkg/pull/52762#issuecomment-4900061907), [#52924](https://github.com/microsoft/vcpkg/pull/52924#pullrequestreview-4709426527)

### PR-004: Complete the new-port checklist truthfully

- **Rule:** New-port PRs must uncomment and complete the new-port checklist from the PR template, not the update checklist or a self-made list. Every tick must be verifiable: a working Repology link, a search-results screenshot, or a genuine Owner-Repo name, plus controlled optional dependencies and license and version scheme matching upstream. Reviewers verify each tick, and a false one is a credibility problem that blocks merge until corrected.
- **Check:** Open `repology.org/project/<name>/versions` and search the web for the name; compare ticked license, versioning, dependency-control, copyright, and usage claims with the port files.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#51110](https://github.com/microsoft/vcpkg/pull/51110#pullrequestreview-4102793453), [#52310](https://github.com/microsoft/vcpkg/pull/52310#pullrequestreview-4472695426)

### PR-005: Demonstrate the problem a fix solves and how

- **Rule:** Fix and scripts PRs must show the concrete failure (triplet, commands, logs, or a reproducible example) on current master and explain the root cause, why the change fixes it, and why CI doesn't already fail. Maintainers won't merge what they can't verify, so claims and new knobs also need evidence or a concrete use case. Workarounds for unexplained behavior aren't merged; use an overlay port until the cause is understood.
- **Check:** The description lacks error output, repro steps, or root-cause analysis; the reviewer can't reproduce the failure on master; or the change patches a consumer for a dependency's bug or adds unexplained flags such as `-fPIC`.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#52127](https://github.com/microsoft/vcpkg/pull/52127#issuecomment-4653580439), [#45763](https://github.com/microsoft/vcpkg/pull/45763#issuecomment-2923605696)

### PR-006: Resolve merge conflicts and regenerate version entries

- **Rule:** Keep the PR free of merge conflicts with master; a conflicted PR is not reviewable and can't be built or merged. Conflicts usually involve `versions/baseline.json` or per-port version files, so after resolving them rerun `vcpkg x-add-version` for the touched ports and commit the result; the push also triggers the fresh CI build reviewers need.
- **Check:** GitHub reports "This branch has conflicts", typically in `versions/baseline.json`, `versions/<x>-/<port>.json`, or files under `ports/<port>/`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Close inactive PRs](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#close-inactive-prs); PRs: [#54777](https://github.com/microsoft/vcpkg/pull/54777#pullrequestreview-5742167634), [#41864](https://github.com/microsoft/vcpkg/pull/41864#issuecomment-2550485371)

### PR-007: Close duplicates and consolidate overlapping open PRs

- **Rule:** Before opening a PR, search open PRs for the same port, version, or touched files. Duplicates are closed in favor of the earlier or more complete PR, or a maintainer rollup, because parallel PRs split review and waste CI; a fix that only makes sense with another in-flight change belongs in that PR as commits, and authors of overlapping work should consolidate instead of competing.
- **Check:** Other open PRs with the same `[port]` title and version or the same touched files, and maintainer comments such as "Duplicate of #N" or "Closing in favor of #N".
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#53885](https://github.com/microsoft/vcpkg/pull/53885#issuecomment-5641214946), [#51792](https://github.com/microsoft/vcpkg/pull/51792#issuecomment-4459340808)

### PR-008: Understand, explain, and accurately describe every change

- **Rule:** The contributor, not an AI tool, is accountable for every line and must explain why each change exists and answer every reviewer question, because maintainers inherit the code; relaying feedback to an LLM and pasting its output back isn't acceptable. The title must say what the PR does (e.g., `[foo] new port`, not "fix foo"), and the description must state the problem and user impact in the contributor's own words.
- **Check:** Unexplained or guessed portfile operations (deleted directories, toggled options), unanswered review threads, long generated descriptions without a concrete problem, or a title that hides a new port, removal, or multi-port change.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#52310](https://github.com/microsoft/vcpkg/pull/52310#discussion_r3400131572), [#55096](https://github.com/microsoft/vcpkg/pull/55096#issuecomment-6997392791)

### PR-009: Escalate policy questions; violating ports aren't precedent

- **Rule:** Existing ports that violate policy, whether merged in error or grandfathered, don't justify repeating the pattern; prior acceptance isn't an exception. Exceptions and new policy (new ecosystems, triplets, deindexing, vendoring or naming exceptions, contested feature designs) are decided in vcpkg team review, and conventions binding other contributors are proposed as vcpkg-docs PRs rather than debated in someone else's port PR, keeping decisions consistent.
- **Check:** Justifications such as "port X already does this", requests for policy exceptions or new categories, and port-PR threads debating general conventions.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); PRs: [#34009](https://github.com/microsoft/vcpkg/pull/34009#issuecomment-1760315969), [#25847](https://github.com/microsoft/vcpkg/pull/25847#pullrequestreview-2104003043)

### PR-010: Use draft status and mark ready after responding

- **Rule:** Open work-in-progress PRs, including transitional designs, as drafts and mark them ready once CI passes. Maintainers convert PRs awaiting contributor action (requested changes, failures, pending upstream or team decisions) to draft and don't review drafts; after addressing or answering all feedback, or declining suggestions labeled optional, the contributor clicks "Ready for review", the only signal available because contributors can't change labels.
- **Check:** Drafts whose feedback was addressed but that weren't marked ready, and ready PRs that still have failing checks or unresolved requested changes.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Use GitHub draft PRs](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#use-github-draft-prs); PRs: [#43180](https://github.com/microsoft/vcpkg/pull/43180#issuecomment-2603520938), [#38928](https://github.com/microsoft/vcpkg/pull/38928#issuecomment-2455476502)

### PR-011: Make one coherent change per PR, usually one port

- **Rule:** A PR should change a single port plus only the downstream fixes the change requires. Put new dependency ports, updates of related ports, new features bundled into a version update, and scripts, triplet, or CI-image changes in separate PRs; tiny tightly coupled additions may be combined when the PR explains the coupling. Smaller PRs review faster, get CI results sooner, and keep a contested part from blocking the rest.
- **Check:** Count `ports/<name>/` directories and `scripts/` or `triplets/` files in the diff; for each beyond the titled port, ask whether the titled change requires it.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Make separate pull requests per port](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#make-separate-pull-requests-per-port); PRs: [#37727](https://github.com/microsoft/vcpkg/pull/37727#pullrequestreview-1992337351), [#54067](https://github.com/microsoft/vcpkg/pull/54067#pullrequestreview-5301503082)

### PR-012: Allow maintainer edits and merge maintainer-supplied fixes

- **Rule:** Open PRs from a personal fork with "Allow edits by maintainers" enabled and no branch rules blocking pushes (organization forks can't grant this), so maintainers can push small fixes such as whitespace or version-database updates directly. When maintainers instead supply fixes as a PR against the contributor's fork, a branch, or a patch, merge them promptly or explain why not; they are often the last blocker.
- **Check:** Maintainer comments reporting denied pushes (e.g., GH013) or linking unmerged fix PRs (`github.com/<contributor>/vcpkg/pull/<n>`), branches, or patches.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#52294](https://github.com/microsoft/vcpkg/pull/52294#pullrequestreview-4481485238), [#54536](https://github.com/microsoft/vcpkg/pull/54536#pullrequestreview-5606795789)

### PR-013: Remove whitespace and line-ending churn from the diff

- **Rule:** Don't change whitespace, CRLF/LF line endings, trailing newlines, or indentation in lines and files the PR doesn't functionally modify, including portfiles, CMake templates, and `versions/*.json`; revert such hunks. Lines added to non-patch files use LF endings without trailing whitespace, and files end with a newline. Churn hides the real change from reviewers and trips the repository's format checks.
- **Check:** A changed file whose `git diff -w` is empty, whole-file diffs from line-ending conversion, trailing spaces, or `\ No newline at end of file`.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Avoid unrelated cosmetic changes](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-trivial-changes-in-untouched-files); PRs: [#53842](https://github.com/microsoft/vcpkg/pull/53842#pullrequestreview-5164063589), [#35047](https://github.com/microsoft/vcpkg/pull/35047#pullrequestreview-1726628679)

### PR-014: Avoid cosmetic-only or no-effect changes to ports

- **Rule:** Don't reformat, rename variables, fix typos, or update `$schema` URLs in ports the PR doesn't otherwise change, and don't touch ports without an upstream change or functional fix. A port-version bump must change what the port produces or fix a real correctness, compatibility, reliability, or reproducibility problem; such fixes aren't cosmetic even if installed files stay the same. Cosmetic changes rebuild ports and dependents for no benefit.
- **Check:** Hunks in otherwise untouched ports that only change formatting or naming, or PRs whose only change is comments, usage wording, description text, or formatting plus a port-version bump.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Avoid unrelated cosmetic changes](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-trivial-changes-in-untouched-files); PRs: [#51646](https://github.com/microsoft/vcpkg/pull/51646#pullrequestreview-4276961765), [#44449](https://github.com/microsoft/vcpkg/pull/44449#issuecomment-2732174606)

### PR-015: Change central or expensive ports only with justification

- **Rule:** Changes to widely depended-on ports (vcpkg-cmake, vcpkg-make, curl, libiconv, qtbase) or very expensive ones (qtwebengine) invalidate everyone's binary caches and trigger large rebuilds. Make them only for a functional need backed by a linked issue, a reproduction, and a look at how upstream and other distributions handle the problem; never incidentally or cosmetically, and update expensive ports in their own PR.
- **Check:** Diffs touching `ports/vcpkg-*` or other high-fan-in or long-build ports with comment, whitespace, or unexplained port-version changes, or justified only by one downstream application's build.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Avoid unrelated cosmetic changes](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-trivial-changes-in-untouched-files); PRs: [#52260](https://github.com/microsoft/vcpkg/pull/52260#discussion_r3477919840), [#51898](https://github.com/microsoft/vcpkg/pull/51898#issuecomment-4568720929)

### PR-016: Check history before reverting deliberate behavior

- **Rule:** Before removing or reverting non-obvious existing behavior, such as an option like `-DBUILD_TOOLS=OFF`, a wrapper, naming, a disabled component, or an earlier bugfix, find the PR that introduced it with git blame and address its rationale in the description. Refine the logic so the original scenario keeps working instead of reverting blindly, which causes bug ping-pong.
- **Check:** The diff deletes or inverts code that an earlier PR added on purpose without referencing that PR, or the description admits the original reason is unknown.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#34466](https://github.com/microsoft/vcpkg/pull/34466#discussion_r1362648080), [#46709](https://github.com/microsoft/vcpkg/pull/46709#issuecomment-3152776112)

### PR-017: Keep iterating in the same PR instead of reopening

- **Rule:** After review starts, push further changes, force-pushing if needed, to the existing PR rather than closing it and opening a new one with the same content. Reopening loses review context, makes it hard to confirm earlier feedback was resolved consistently, sends the change to the back of the queue, and wastes CI. If resubmitting is unavoidable, link the earlier PR and apply its feedback.
- **Check:** A new PR for the same port from the same author shortly after a closed one with unresolved review threads, or a resubmission that reintroduces issues already pointed out.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#52429](https://github.com/microsoft/vcpkg/pull/52429#pullrequestreview-4512283673), [#30058](https://github.com/microsoft/vcpkg/pull/30058#issuecomment-1470938756)

### PR-018: Declare prerequisite PRs and build on them after merge

- **Rule:** Branch each PR from current master without commits from the contributor's other PR branches. If a PR needs another open PR, say "Depends on #N" instead of copying its changes, because a dependent change can't be validated or merged first; maintainers label it `depends:different-pr`. Once the prerequisite lands, merge master and drop workarounds, such as patches, that it made unnecessary.
- **Check:** Commits or ports copied from another open PR, the `depends:different-pr` label, or patches duplicating a change that has since merged.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#51358](https://github.com/microsoft/vcpkg/pull/51358#pullrequestreview-4173291038), [#37119](https://github.com/microsoft/vcpkg/pull/37119#issuecomment-2033008689)

### PR-019: Verify AI-generated findings before reporting them

- **Rule:** Treat AI review output as leads, not verdicts, because much of it can be wrong: confirm each finding by source tracing, reproduction, or baseline comparison before posting, drop wrong or irrelevant items, and say which were confirmed. Evaluate contributor rebuttals backed by upstream evidence instead of dismissing them, and when confirmed bugs go upstream, respect upstream contribution policies, such as bans on AI-generated patches.
- **Check:** Review comments relaying AI output without confirmation or with irrelevant items, and contributor counter-evidence, such as a top-level LICENSE file, left unevaluated.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: AI-identified bugs in new ports](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ai-identified-bugs-in-new-ports); PRs: [#51531](https://github.com/microsoft/vcpkg/pull/51531#pullrequestreview-4224869614), [#52719](https://github.com/microsoft/vcpkg/pull/52719#pullrequestreview-4667770063)

### PR-020: Close PRs waiting on the contributor for 60 days

- **Rule:** A PR waiting more than 60 days for contributor action (unexplained failing checks, unanswered requested changes, or merge conflicts) may be closed as stale to keep the review queue actionable. The countdown doesn't run while the PR awaits build-lab verification or maintainer review, and a substantive response resets it. Closing is now automated; to continue, the contributor opens a new PR.
- **Check:** Compare the latest maintainer request or failing run with the contributor's last substantive reply or commit, and look for unanswered "Is there any new progress?" pings.
- **Severity:** advisory · **Scope:** all
- **Sources:** [Maintainer guide: Close inactive PRs](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#close-inactive-prs); PRs: [#52688](https://github.com/microsoft/vcpkg/pull/52688#issuecomment-6839293303), [#50061](https://github.com/microsoft/vcpkg/pull/50061#issuecomment-4712227301)

### PR-021: Avoid pushes that only restart CI

- **Rule:** Don't rebase, force-push, or merge master just to refresh a branch: CI tests a merge commit with master and PRs are squash-merged, so such pushes only restart expensive builds, which for world-rebuild PRs discards days of build-lab work. Let a CI run finish before pushing again, and don't push rapid iterations of scripts/ PRs while the design is under discussion.
- **Check:** Repeated "Merge branch 'master'" commits or force-pushes without content changes, or pushes that cancel in-progress CI runs.
- **Severity:** advisory · **Scope:** all
- **Sources:** PRs: [#54969](https://github.com/microsoft/vcpkg/pull/54969#issuecomment-6807552864), [#54630](https://github.com/microsoft/vcpkg/pull/54630#discussion_r4369846414)

### PR-022: Apply info:reviewed only to PRs ready for maintainers

- **Rule:** Triage reviewers apply the `info:reviewed` label once a PR passes the PR review checklist and needs nothing more from the contributor, handing it to vcpkg maintainers for final review and merge. Don't apply it while requested changes or failing checks remain, and remove it when new blocking problems appear, such as upstream merging a different fix than the one backported.
- **Check:** The PR's labels versus outstanding requested changes, failing checks, or newly found blocking issues.
- **Severity:** advisory · **Scope:** all
- **Sources:** [PR review checklist: Overview](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#overview); PRs: [#44454](https://github.com/microsoft/vcpkg/pull/44454#pullrequestreview-2692565650), [#41819](https://github.com/microsoft/vcpkg/pull/41819#issuecomment-2443038272)

### PR-023: Keep the update checklist and link fixed issues

- **Rule:** Port-update PRs uncomment and complete the update checklist from the PR template: maintainer-guide compliance, updated SHA512s, re-evaluated `supports`, fixed CI baseline entries removed, all patches applying, and the version database regenerated with exactly one new version per file. Any PR that fixes issues lists each as `Fixes #NNN` so it closes on merge.
- **Check:** The PR body lacks the matching checklist, leaves items unchecked without explanation, or ticks items the diff contradicts, such as stale SHA512s or baseline entries.
- **Severity:** advisory · **Scope:** all
- **Sources:** [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md)

## NEW: New port acceptance

### NEW-001: Reject immature projects; suggest overlays or custom registries

- **Rule:** A new port's component needs a release at least six months old, six months of active public development, official membership in a project meeting that bar, or equivalent demonstrated maturity. Private development time, code quality, CI coverage, or filling a registry gap don't substitute. Close immature submissions with a pointer to overlay ports or a custom registry, because every curated port carries ongoing maintenance cost.
- **Check:** Compare upstream's repository creation, first public commit, and first release dates with the PR date; scrutinize "Some other reason" checklist claims, bursts of same-day releases, stub-heavy code, frequent renames, and absence from search results.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [Maintainer guide: Packaged components should be mature](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#packaged-projects-should-be-mature); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#55108](https://github.com/microsoft/vcpkg/pull/55108#issuecomment-6958420978), [#53328](https://github.com/microsoft/vcpkg/pull/53328#pullrequestreview-4901564826)

### NEW-002: Use Repology or search-associated names, else owner-repo form

- **Rule:** A new port's name must lead to its component: use its Repology or distro package name, or a name strongly associated with it in web searches, and otherwise `<github-owner>-<repo>`. The test is "strongly associated", not "currently unused", and upstream's own name shouldn't be reinvented (cpprealm for realm-cpp). Only the port name is constrained, not library, header, or CMake names, because a published name can never be reassigned.
- **Check:** Look up repology.org/project/<name> and search "<name>" and "<name> C++"; compare hits with the upstream owner/repository and existing ports, and verify the PR template's naming checkbox (with its search screenshot) instead of trusting it.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [Maintainer guide: Use distinctive port names](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#check-names-against-other-repositories); [PR review checklist c000009](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000009); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#37471](https://github.com/microsoft/vcpkg/pull/37471#issuecomment-2016244451), [#50013](https://github.com/microsoft/vcpkg/pull/50013#issuecomment-3917022150)

### NEW-003: Prefix short, generic, or affix-only names with the owner

- **Rule:** Short or common-word names, and names whose stem collides with other projects after stripping cpp, free, lib, open, and numerals, need an owner or organization prefix; those affixes never disambiguate. Suite or brand prefixes (boost-, bext-, google-) are reserved for official members. Unprefixed exceptions need evidence, such as the same name in curated distros or a Repology collision only with a long-dead project.
- **Check:** Reduce the name to its stem and search Repology and the web for it; reject `cpp-<stem>`, `lib<stem>`, or `<stem>6` as disambiguation, and for `<suite>-*` names confirm the repository belongs to the suite's official organization.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [Maintainer guide: Example: Ambiguous port name](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#example-ambiguous-port-name); [Maintainer guide: Use distinctive port names](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#check-names-against-other-repositories); PRs: [#51596](https://github.com/microsoft/vcpkg/pull/51596#discussion_r3210714772), [#45125](https://github.com/microsoft/vcpkg/pull/45125#pullrequestreview-2792638249)

### NEW-004: Reject ports that can't install alongside existing ports

- **Rule:** Every curated port must install and link alongside all others, since CI tests the registry as one combination: no files owned by another port, no vendored copies or forks exporting another port's symbols, and no probing for other ports except through declared dependencies. Conflicts are resolved in favor of the already indexed port; exceptions are official successors, ports without platform overlap, and grandfathered ports with significant users.
- **Check:** Search existing ports for the same homepage or similar names; compare installed include/, lib/, share/, and CMake package/target names, watch for FILE_CONFLICTS or "already installed" errors, and inspect exports (dumpbin /exports, nm) for third-party symbols.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); [Maintainer guide: Unique port attribution rule](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#unique-port-attribution-rule); PRs: [#49666](https://github.com/microsoft/vcpkg/pull/49666#issuecomment-4060263732), [#54250](https://github.com/microsoft/vcpkg/pull/54250#issuecomment-5966599320)

### NEW-005: Reject ports for abandoned or unreachable upstreams

- **Rule:** Don't add ports for inactive components: abandoned or archived projects, repositories not accepting contributions, unresponsive or unreachable maintainers, long-unfixed CVEs, or no meaningful changes for a long time. vcpkg must be able to take problems and patches upstream rather than become the de facto maintainer. Foundational, stable components such as zlib are the exception.
- **Check:** Check upstream for archived or abandoned notices, last meaningful commit and release dates, open CVEs, a working issue tracker or PR venue, and responses to the contributor's upstream reports.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [Maintainer guide: Packaged components should be stable and actively maintained](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#packaged-projects-should-be-stable-and-actively-maintained); PRs: [#53208](https://github.com/microsoft/vcpkg/pull/53208#issuecomment-5199022877), [#52281](https://github.com/microsoft/vcpkg/pull/52281#discussion_r3400054989)

### NEW-006: Require CI testing on at least one official triplet

- **Rule:** Every port must build and be tested in CI on at least one official triplet; helper and tool ports need a smoke test. Ports needing SDKs, toolchains, or interactive installs that CI lacks aren't accepted until CI provisioning is extended; adding such a requirement to an existing port is a regression. Keep needs like CUDA or proprietary compilers behind optional features so default builds work on a typical developer workstation.
- **Check:** Flag "supports" or ci.baseline.txt entries leaving no official triplet tested, all-skipped CI results, portfile errors demanding manually installed SDKs or compilers, and new dependencies of existing ports that CI can't build.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must be tested in at least one official triplet](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-be-tested-in-at-least-one-official-triplet); [PR review checklist c000006](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000006); PRs: [#54264](https://github.com/microsoft/vcpkg/pull/54264#issuecomment-6026412752), [#33304](https://github.com/microsoft/vcpkg/pull/33304#issuecomment-1709251141)

### NEW-007: Package the official upstream project, not a fork

- **Rule:** A port named after a project must fetch that project's official upstream. Forks are acceptable only as recognized successors, when the original is unavailable and there is substantial community interest, or, rarely, when they demonstrably track a live upstream including security fixes; unless a fork has completely superseded the original, it needs its own name and a description saying so. Carry small fork changes as patches on upstream sources instead.
- **Check:** Compare the vcpkg_from_* REPO/URL owner with the official repository, homepage, and Repology entry; check how far a fork lags upstream (including security fixes), whether its versioning diverges, and how small its diff to upstream is.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist c000008](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000008); PRs: [#33246](https://github.com/microsoft/vcpkg/pull/33246#issuecomment-1710785895), [#18029](https://github.com/microsoft/vcpkg/pull/18029#discussion_r822167313)

### NEW-008: Build from source; reject prebuilts exposing curated dependencies

- **Rule:** Binary-only ports are strongly discouraged and are rejected when the binaries bundle or require dependencies provided by curated ports and expose them to consumers' link domain (libraries, headers, CMake or pkg-config files), which locks the dependency graph and risks ODR, ABI, and security problems. Prebuilts ignoring the triplet's toolchain, linkage, or CRT are rejected too; isolated host-only tools, self-contained link domains, and data-only packages are tolerated.
- **Check:** Look for portfiles downloading zip/nupkg/tarballs of .dll/.lib/.so instead of sources; inspect `dumpbin /dependents` or `ldd`, installed headers, and config files for vcpkg-provided libraries, and compare the binaries' linkage and CRT with the triplet.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Installing prebuilt binaries](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#installing-prebuilt-binaries); PRs: [#54684](https://github.com/microsoft/vcpkg/pull/54684#pullrequestreview-5808765304), [#40587](https://github.com/microsoft/vcpkg/pull/40587#issuecomment-2305476038)

### NEW-009: Update existing ports instead of adding versioned or variant copies

- **Rule:** Don't add major-version, legacy, backend, or build-variant copies of an existing port; update the existing port, since older versions stay reachable through versioning and overrides. A version-suffixed port is acceptable only when upstream maintains both lines for side-by-side use with distinct library, header, and CMake names; lockstep add-ons become main-port features. Backports of older release lines are accepted only from the component's author.
- **Check:** Flag new ports named like an existing port plus a version or backend suffix (openssl-1, <name>2, onnxruntime-cuda12) or fetching the same repository; check upstream's support policy for the old line and whether names would collide.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); PRs: [#50690](https://github.com/microsoft/vcpkg/pull/50690#issuecomment-4207977542), [#38275](https://github.com/microsoft/vcpkg/pull/38275#issuecomment-2097019324)

### NEW-010: Add conflicting successors or forks only as replacements

- **Rule:** A fork or successor that conflicts with an existing port may enter only as its official replacement: the same PR removes the old port, migrates its dependents, and leaves an empty forwarding port if consumers need one. Repoint an existing port name to a fork or new owner only when that project has clearly and completely superseded the original; otherwise add a separate `<owner>-<repo>` port.
- **Check:** For overlapping new ports, confirm the old upstream is abandoned or officially succeeded, the old port is deleted in the same PR, and its dependents are migrated; flag updates that switch REPO or homepage to another owner.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); PRs: [#46990](https://github.com/microsoft/vcpkg/pull/46990#issuecomment-3250656168), [#26301](https://github.com/microsoft/vcpkg/pull/26301#issuecomment-1397676179)

### NEW-011: Package libraries, not applications or standalone tools

- **Rule:** The curated registry is for C/C++ libraries; vcpkg isn't an application or tool deployment system and doesn't compete with apt, pip, or npm. Tool-only ports are accepted when the tool must match a registry library (protoc with protobuf); generic build tools come from vcpkg_find_acquire_program or the system. Reject application or server ports, pip or npm wrappers, custom-patched tool forks, and ports that sidestep compliance rules.
- **Check:** Flag new ports that install only executables or Python packages, shell out to npm or pip, wrap general-purpose build tools, or are justified by build speed or avoiding compliance warnings; ask how C/C++ consumers would use them.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [Installation layout: tools/<port>](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-tools); PRs: [#40880](https://github.com/microsoft/vcpkg/pull/40880#issuecomment-2339549175), [#42480](https://github.com/microsoft/vcpkg/pull/42480#issuecomment-2516174643)

### NEW-012: Report AI-identified bugs in new ports upstream

- **Rule:** When AI code review finds a bug in a new port's upstream code, the contributor must report it upstream, using the security process if it may be exploitable, even if the port doesn't patch that code. Upstream's "not a bug" verdict is final, and a fixed release or upstream-approved patch is accepted; without an upstream response within 30 days, the submission is closed.
- **Check:** Look for AI review findings on the PR without a linked upstream issue, security report, or fix, and compare the report date with the 30-day window.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [Maintainer guide: AI-identified bugs in new ports](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ai-identified-bugs-in-new-ports); PRs: [#54545](https://github.com/microsoft/vcpkg/pull/54545#issuecomment-6330855274), [#53948](https://github.com/microsoft/vcpkg/pull/53948#issuecomment-5739593130)

### NEW-013: Never invoke programs that modify the user's system

- **Rule:** Ports must not run `sudo`, `apt`, `brew`, `npm install`, system-wide `pip install`, or similar programs that modify the user's machine; use vcpkg ports or vcpkg-acquired tools, or tell the user what to install. vcpkg's contract is to leave the user's system untouched, and CI machines can't be reset after a PR installs something on them.
- **Check:** Grep portfile.cmake and the scripts it runs for `execute_process` or `vcpkg_execute_*` calls to `sudo`, `apt`, `brew`, `pip install`, `npm install`, or other package managers; PRs adding such installs to CI provisioning.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist c000011](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000011)

### NEW-014: Keep established port names stable

- **Rule:** Don't rename established ports, even to free a name or make it more accurate, because renames break existing users. When a rename is unavoidable, do it at most once in any 12-month period and move the ports/ directory, the manifest "name", and the versions database entries together.
- **Check:** Flag PRs that delete one port directory and add another for the same project or repurpose an existing name; check the port's rename history and that versions/ files exist for the new name.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [Maintainer guide: Limit port renames](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#limit-port-renames); PRs: [#35032](https://github.com/microsoft/vcpkg/pull/35032#issuecomment-1839816922), [#22442](https://github.com/microsoft/vcpkg/pull/22442#issuecomment-1008611412)

### NEW-015: Show a minimal consumer when usage isn't obvious

- **Rule:** When it isn't obvious how a new port is consumed (plugins, resource or source drops, SDKs bound to an external runtime, several related ports at once), the contributor must show the shortest working consumer: a vcpkg.json, CMakeLists.txt, and source file, or an end-to-end deployment story. Maintainers judge practical usability and registry integrity, not the library's domain merits.
- **Check:** New ports whose installed files aren't an ordinary library or header set, or whose integration is undocumented; request a minimal consumer (for example, in a gist) and verify it builds against the installed port.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** PRs: [#26768](https://github.com/microsoft/vcpkg/pull/26768#issuecomment-1292584895), [#43566](https://github.com/microsoft/vcpkg/pull/43566#discussion_r1962266946)

### NEW-016: Don't add meta-ports or repackage vendor SDK components

- **Rule:** Don't add aggregate meta-ports over independently released libraries (such as an x11 port for all libx*); they fit only when upstream ships one hermetic release, as boost and Qt do, and a concrete need is shown. Consume components a vendor ships inside its SDK installer (NVTX in the CUDA toolkit) from that SDK instead of repackaging them as ports.
- **Check:** New ports whose vcpkg.json only lists dependencies on independently released libraries, or whose headers and libraries ship in an SDK (CUDA, etc.) that related ports already require.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** PRs: [#22642](https://github.com/microsoft/vcpkg/pull/22642#issuecomment-1212357714), [#46800](https://github.com/microsoft/vcpkg/pull/46800#issuecomment-3169469749)

### NEW-017: Deindex unmaintained ports instead of patching around them

- **Rule:** Don't keep unmaintained ports alive with accumulating product-code patches; vcpkg isn't a maintainer of last resort, though small compatibility fixes may still be taken with a warning. When such a port blocks dependency updates, carries unfixed CVEs, or no longer builds anywhere, deindex it after handling its consumers instead of hiding failures with CI skips. Ports of discontinued projects stay while still usable.
- **Check:** Look for archived upstreams with high port-version counts, patches touching product code, ports blocking updates of dependencies such as ffmpeg or boost, and ports failing or skipped on every CI triplet.
- **Severity:** non-blocking · **Scope:** port-update
- **Sources:** [Maintainer guide: Packaged components should be stable and actively maintained](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#packaged-projects-should-be-stable-and-actively-maintained); [Maintainer guide: Ports must be tested in at least one official triplet](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-be-tested-in-at-least-one-official-triplet); PRs: [#51307](https://github.com/microsoft/vcpkg/pull/51307#pullrequestreview-4149833182), [#47117](https://github.com/microsoft/vcpkg/pull/47117#discussion_r2320122764)

## VER: Versioning and version database

### VER-001: Give every modified port one new version per PR

- **Rule:** Any change under `ports/<name>/` (portfile, patches, usage, `vcpkg.json`, even comments) needs one new version of that port per PR, not per commit: increment `"port-version"` when the upstream version is unchanged; otherwise change the version and reset `"port-version"` by removing it. New ports omit `"port-version"`, and changes confined to `scripts/` need no bump. Each version maps to one immutable git tree that users and binary caches rely on.
- **Check:** Port files changed while the version and `"port-version"` match master; a changed version that keeps a non-zero `"port-version"`; `"port-version"` raised by more than one or non-zero in a new port; CI `checked-in files for <port> have changed but the version was not updated`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Update the port-version field](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#update-the-port-version-field-in-the-manifest-file-of-any-modified-ports); [Versioning reference: port-version](https://learn.microsoft.com/vcpkg/users/versioning#port-version); [PR review checklist: c000002](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000002); PRs: [#44449](https://github.com/microsoft/vcpkg/pull/44449#issuecomment-2732174606), [#34909](https://github.com/microsoft/vcpkg/pull/34909#issuecomment-1899539314)

### VER-002: Generate and refresh versions/ entries with x-add-version

- **Rule:** Record each modified port in `versions/baseline.json` and `versions/<x>-/<port>.json` by running `vcpkg x-add-version <port>` (or `--all`) on the final, committed port directory without stray untracked files; never hand-edit or hand-merge these files. After any later review change rerun it with `--overwrite-version`; after merge conflicts take master's `versions/`, bump above any version master published meanwhile, and regenerate, because CI verifies every recorded git-tree against the port.
- **Check:** Port changes without matching `versions/` updates; a new port missing either file; hand-edited git-trees or JSON; CI errors "git tree ... does not match the port directory" or "local port with the same version has a different SHA" (compare with `git rev-parse HEAD:ports/<port>`).
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Update the version files](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#update-the-version-files-in-versions-of-any-modified-ports); [x-add-version: --overwrite-version](https://learn.microsoft.com/vcpkg/commands/add-version#--overwrite-version); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#51237](https://github.com/microsoft/vcpkg/pull/51237#pullrequestreview-4367532908), [#37157](https://github.com/microsoft/vcpkg/pull/37157#pullrequestreview-1926177645)

### VER-003: Add exactly one entry per port; never alter published ones

- **Rule:** Each modified `versions/<x>-/<port>.json` gains exactly one new entry describing the PR's final state; PRs are squash-merged, so intermediate versions would never exist. Entries already on master are immutable: never change their version or git-tree, delete them, insert versions vcpkg never published, or touch entries of ports the PR doesn't modify; fix a published mistake with a new `"port-version"`.
- **Check:** A versions-file diff that adds more than one object or edits or removes existing ones; a baseline `"port-version"` more than one above master's; `baseline.json` or `versions/` hunks for ports unchanged under `ports/`.
- **Severity:** blocking · **Scope:** versions
- **Sources:** [Maintainer guide: Update the version files](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#update-the-version-files-in-versions-of-any-modified-ports); [Registries: Adding a new version](https://learn.microsoft.com/vcpkg/concepts/registries#git-add-version); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#48922](https://github.com/microsoft/vcpkg/pull/48922#discussion_r2628616654), [#49397](https://github.com/microsoft/vcpkg/pull/49397#pullrequestreview-3748120825)

### VER-004: Declare exactly the upstream release the port builds

- **Rule:** The declared version must be the upstream release the port downloads and builds on every triplet: REF or URL at that release's tag, the release's changed components actually built, and a number upstream published (not 0.0.1 for release 0.06). Moving REF/SHA512 to other upstream content requires a new version, not just a `"port-version"` bump, because users and constraints rely on version X meaning upstream's X.
- **Check:** Compare the version with REF, tags, release URLs, and any per-platform REF/URL/SHA512 branches; flag REF moved past the tag with only `"port-version"` bumped, versions absent upstream, and installed ConfigVersion or `.pc` versions that reveal a different release.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Follow common conventions for the version field](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#follow-common-conventions-for-the-version-field); [Versioning reference: port-version](https://learn.microsoft.com/vcpkg/users/versioning#port-version); PRs: [#53209](https://github.com/microsoft/vcpkg/pull/53209#pullrequestreview-4858429395), [#41420](https://github.com/microsoft/vcpkg/pull/41420#issuecomment-2400694824)

### VER-005: Follow the component's own versioning and keep the scheme

- **Rule:** Number the port the way the packaged component itself releases, using the matching scheme, not by a specification it implements, an SDK that bundles it, or a separate build repository; repology shows how other distributions number it. On updates keep the existing scheme unless upstream's convention changed (moving off `"version-string"` to an orderable scheme is welcome): vcpkg never compares across schemes, so a switch breaks users' `version>=` constraints and baselines.
- **Check:** `vcpkg.json` diffs that rename the version key (e.g., `"version"` to `"version-date"` or `"version-string"`) or change the numbering basis; compare with upstream tags and `https://repology.org/project/<name>/versions`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Follow common conventions for the version field](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#follow-common-conventions-for-the-version-field); [Versioning troubleshooting: Version scheme conflict](https://learn.microsoft.com/vcpkg/users/versioning-troubleshooting#version-scheme-conflict); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#49228](https://github.com/microsoft/vcpkg/pull/49228#discussion_r2670086426), [#36111](https://github.com/microsoft/vcpkg/pull/36111#issuecomment-1888495007)

### VER-006: Use "version" for numeric releases, never "version-string"

- **Rule:** Declare dot-separated numeric releases (2.14, 0.168.7) with `"version"`, dropping leading zeros (25.05.01 becomes 25.5.1, with the padded form rebuilt from `${VERSION}` where tags or URLs need it). `"version-string"` can't be ordered, so `version>=` degrades to an exact match and forces users into overrides; reserve it for versions no orderable scheme can express (e.g., 0.1.2c).
- **Check:** `"version-string"` values matching `^\d+(\.\d+)*$` or with zero-padded numeric parts; the x-add-version message `Use the version scheme "version" instead of "version-string"`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Versioning reference: Version schemes](https://learn.microsoft.com/vcpkg/users/versioning#version-schemes); [Versioning reference: version](https://learn.microsoft.com/vcpkg/users/versioning#version); PRs: [#37563](https://github.com/microsoft/vcpkg/pull/37563#issuecomment-2026170317), [#49228](https://github.com/microsoft/vcpkg/pull/49228#discussion_r2659519635)

### VER-007: Use "version-date" only for projects without releases

- **Rule:** Live-at-HEAD projects without versioned releases use `"version-date"` with the YYYY-MM-DD date of the packaged commit, not invented numbers such as 0.0.0 or dates in `"version-string"`. Once upstream tags a release, package it with `"version"` and REF set to that tag. `"version-date"` is the scheme meant for unreleased projects, and invented numbers mislead users.
- **Check:** `"version": "0.0.0"` or numbers absent from upstream tags combined with a commit-hash REF; `"version-string"` holding a date; `"version-date"` on a project whose packaged commit is a tagged release.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Versioning reference: version-date](https://learn.microsoft.com/vcpkg/users/versioning#version-date); [vcpkg.json: version](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#version); PRs: [#29714](https://github.com/microsoft/vcpkg/pull/29714#discussion_r1111538627), [#43036](https://github.com/microsoft/vcpkg/pull/43036#issuecomment-2628812626)

### VER-008: Package upstream releases, not unreleased commits

- **Rule:** Package upstream's tagged releases. Don't move REF to newer commits or switch to `"version-date"` (or `vcpkg_from_git`) to pick up unreleased changes, which may not be production ready and have broken users. Backport required fixes, including the contributor's own merged upstream fixes, as patches (preferably downloaded from the upstream commit), don't import unreleased interface changes such as new CMake namespaces, and ask upstream to tag a release; exceptions need fixes every user needs and, ideally, upstream agreement.
- **Check:** REF changed from a tag to a commit SHA, or `"version"` switched to `"version-date"`, while upstream publishes tags; justifications like "need latest master"; repology showing other distributions on the last release.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Follow common conventions for the version field](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#follow-common-conventions-for-the-version-field); PRs: [#38161](https://github.com/microsoft/vcpkg/pull/38161#issuecomment-2166826988), [#34523](https://github.com/microsoft/vcpkg/pull/34523#issuecomment-1767241153)

### VER-009: Make each new version sort above published ones

- **Rule:** A new version must sort above every published version of the port, because baselines and `version>=` assume monotonic order. Watch upstream renumbering (e.g., 2017-9 to 2.2.0) and suffixes: "-" marks a pre-release, so 3.2-6e300997 sorts before 3.2 and semver ranks 2.0.0-rc9 above 2.0.0-rc13, while "+build" metadata and commit hashes give no ordering. Maintainer-approved snapshots use a pre-release of the next version (e.g., 3.4.1-0.20250425).
- **Check:** Compare old and new strings with the scheme's ordering rules; flag decreases, a "-" suffix on an already-published base version, "+" metadata, and hex commit IDs in version strings.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [Versioning reference: Version schemes](https://learn.microsoft.com/vcpkg/users/versioning#version-schemes); PRs: [#37563](https://github.com/microsoft/vcpkg/pull/37563#discussion_r1536452701), [#30196](https://github.com/microsoft/vcpkg/pull/30196#discussion_r1187983895)

### VER-010: Build against baseline versions; never pin dependency versions

- **Rule:** Curated ports must build with the dependency versions in the current baseline: `"overrides"`, baselines, and `vcpkg-configuration.json` pins work only in top-level projects, and upper bounds don't exist. If an update needs a newer dependency or breaks dependents, update or patch those ports in the same PR, moving coupled families (protobuf/grpc, spirv-headers/spirv-tools) together to upstream-compatible versions; never pin or fall back to vendored copies.
- **Check:** Upstream minimum versions vs `versions/baseline.json`; configure logs rejecting the vcpkg package or using a bundled copy; `"overrides"` or pinning proposals in port manifests or PR text; patches forcing mismatched family versions; CI regressions in dependents.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [Maintainer guide: Version constraints in ports](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#version-constraints-in-ports); [Maintainer guide: Make separate pull requests per port](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#make-separate-pull-requests-per-port); [vcpkg.json: overrides](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#overrides); PRs: [#46176](https://github.com/microsoft/vcpkg/pull/46176#issuecomment-3009769625), [#54052](https://github.com/microsoft/vcpkg/pull/54052#pullrequestreview-5297935553)

### VER-011: Reference only versions that exist in the version database

- **Rule:** Every `version>=` must name, in the dependency's scheme, a version recorded in `versions/<x>-/<dep>.json`, normally the first suitable version vcpkg actually published rather than an upstream release vcpkg never shipped; add prerequisite dependency updates first or in the same PR. vcpkg can only interpret versions that exist in the database.
- **Check:** CI errors that a `version>=` constraint names a version which does not exist in the version database; compare each constraint with the dependency's versions file.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Versioning troubleshooting: Non-existent version](https://learn.microsoft.com/vcpkg/users/versioning-troubleshooting#non-existent-version); PRs: [#54492](https://github.com/microsoft/vcpkg/pull/54492#issuecomment-6321513903), [#54534](https://github.com/microsoft/vcpkg/pull/54534#issuecomment-6330883539)

### VER-012: Keep version history when removing or renaming ports

- **Rule:** When deindexing or renaming a port, delete `ports/<name>`, its `versions/baseline.json` entry, and its `scripts/ci.baseline.txt` and `ci.feature.baseline.txt` entries, but keep `versions/<x>-/<name>.json` so users can still reach old versions through overrides. For renames, update every dependent and mention the old name in the new port's description; keep a stub that depends on the new port only when a transition period is needed.
- **Check:** Deleted `versions/*/<name>.json` files; baseline or CI-baseline entries left for a deleted port; dependents still naming the old port; stub ports kept without dependents or a transition need.
- **Severity:** blocking · **Scope:** versions
- **Sources:** [Registries concepts](https://learn.microsoft.com/vcpkg/concepts/registries); PRs: [#38346](https://github.com/microsoft/vcpkg/pull/38346#issuecomment-2078276157), [#22012](https://github.com/microsoft/vcpkg/pull/22012#issuecomment-1317377730)

### VER-013: Follow the release series upstream designates as current

- **Rule:** A port follows the release series upstream designates as current, not preview or development series. Update it to new majors even when they drop platforms or break APIs, adjusting `"supports"` and dependents, rather than holding it back or maintaining backports for dropped platforms; vcpkg promises no source compatibility across updates, and users who need an older version pin it with overrides or overlay ports.
- **Check:** Updates moving a port to a preview or development series; PRs refusing an upstream major, or keeping old versions alive, only to preserve platforms upstream dropped.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** PRs: [#34316](https://github.com/microsoft/vcpkg/pull/34316#issuecomment-1756531786), [#32432](https://github.com/microsoft/vcpkg/pull/32432#issuecomment-1636472330)

### VER-014: Avoid "version>=" in ports without a hard requirement

- **Rule:** Add `version>=` to a port's dependencies only when upstream's build hard-requires that minimum (e.g., `find_package(xchange 1.3 REQUIRED)`) or the ports form a suite whose versions must match (Boost, Qt), never for parity. Constraints are minimums only, CI tests only the latest versions, and they hinder the ports' independent evolution.
- **Check:** New `version>=` entries in `ports/*/vcpkg.json`; ask for the upstream requirement that justifies each one.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Version constraints in ports](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#version-constraints-in-ports); PRs: [#49463](https://github.com/microsoft/vcpkg/pull/49463#discussion_r2700026667), [#39886](https://github.com/microsoft/vcpkg/pull/39886#discussion_r1694225128)

### VER-015: Use "version-semver" only when upstream promises SemVer

- **Rule:** Declare `"version-semver"` only when upstream documents that it follows Semantic Versioning; otherwise use `"version"`, which also accepts semver-like strings. The semver scheme asserts strict SemVer precedence and compatibility that the project may not honor.
- **Check:** New or changed `"version-semver"` in `vcpkg.json`; look for an explicit SemVer statement in upstream's README or documentation.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Versioning reference: version-semver](https://learn.microsoft.com/vcpkg/users/versioning#version-semver); PRs: [#28668](https://github.com/microsoft/vcpkg/pull/28668#pullrequestreview-1278364505), [#29027](https://github.com/microsoft/vcpkg/pull/29027#discussion_r1073188502)

### VER-016: Don't add version database entries for test ports

- **Rule:** Test ports under `scripts/test_ports` are overlay ports outside the registry. They get no `versions/` entries or `baseline.json` keys and need no `x-add-version` run.
- **Check:** New `versions/` files or `baseline.json` keys for ports that live under `scripts/test_ports` (for example `vcpkg-ci-*` ports).
- **Severity:** non-blocking · **Scope:** versions
- **Sources:** PRs: [#39285](https://github.com/microsoft/vcpkg/pull/39285#issuecomment-2167708488)

## MAN: Manifest (vcpkg.json)

### MAN-001: Use a valid vcpkg.json in ports/<name>, never CONTROL

- **Rule:** Each port lives in ports/<name>/ with portfile.cmake and a valid JSON manifest named exactly vcpkg.json. New ports must not use CONTROL files, and significantly modified ports should be converted with `vcpkg format-manifest`. A misplaced, misnamed, or malformed manifest means CI never builds or validates the port.
- **Check:** Confirm ports/<name>/vcpkg.json exists and parses, no CONTROL file is added, no files sit in nested or wrong folders, and CI logs show the port was actually built.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist c000013](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000013); [Maintainer guide: Manifests](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#manifests); PRs: [#30742](https://github.com/microsoft/vcpkg/pull/30742#issuecomment-1509593715), [#51232](https://github.com/microsoft/vcpkg/pull/51232#issuecomment-4286416066)

### MAN-002: Format every changed manifest with vcpkg format-manifest

- **Rule:** Every added or modified vcpkg.json, including scripts/test_ports manifests, must match `vcpkg format-manifest` output, and edited CI baseline files must match `vcpkg format-feature-baseline`. The PR workflow fails otherwise and publishes a format diff you can apply with `git apply`; formatted manifests keep diffs canonical.
- **Check:** CI formatting failures ("The formatting of the files in the repo were not what we expected") or key order and indentation differing from `vcpkg format-manifest` output.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Manifests](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#manifests); [untrustedPR workflow](https://github.com/microsoft/vcpkg/blob/master/.github/workflows/untrustedPR.yml); PRs: [#45395](https://github.com/microsoft/vcpkg/pull/45395#discussion_r2076335863), [#29714](https://github.com/microsoft/vcpkg/pull/29714#discussion_r1111538627)

### MAN-003: Mark build-time tool and helper dependencies as host

- **Rule:** Dependencies whose tools or scripts run during the build (vcpkg-cmake, vcpkg-cmake-config, vcpkg-tool-* ports, generators such as gperf or ragel) must use `"host": true`, even when platform-qualified, and each vcpkg helper the portfile calls needs its providing port declared. Exception: helper ports depend on other helper ports without host. Without host, cross-compiling builds these tools for a target where they can't run.
- **Check:** Flag tool or helper ports in "dependencies" without `"host": true`, helper calls such as vcpkg_cmake_configure without the matching helper dependency, and "Exec format error" or unsupported-triplet failures in cross-compiling CI jobs.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: host](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#dependency-host); [Authoring script ports](https://learn.microsoft.com/vcpkg/maintainers/authoring-script-ports#how-do-they-work); [Maintainer guide: Avoid deprecated helper functions](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-deprecated-helper-functions); PRs: [#55005](https://github.com/microsoft/vcpkg/pull/55005#pullrequestreview-5867883796), [#49463](https://github.com/microsoft/vcpkg/pull/49463#discussion_r2700026667)

### MAN-004: Describe the port and every feature in English

- **Rule:** Every port needs a non-empty English "description" of one to a few sentences, preferably upstream's own summary (automatic translations are fine), and every feature needs a description because the schema requires one. Never delete an existing description; descriptions drive `vcpkg search` and listings.
- **Check:** New ports or features with a missing, empty, placeholder, or non-English "description", and diff hunks that delete one.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist c000003](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000003); [vcpkg.json reference: feature description](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#feature-description); PRs: [#42480](https://github.com/microsoft/vcpkg/pull/42480#discussion_r1870923797), [#35032](https://github.com/microsoft/vcpkg/pull/35032#discussion_r1416847467)

### MAN-005: Declare license as a valid SPDX expression or null

- **Rule:** New ports must declare "license" as an SPDX 3.19 expression matching upstream's grant (no DocumentRefs or free text), or null when no SPDX expression fits and users must read the installed copyright file; reviewers also request it when touching ports that lack one. License metadata feeds SBOMs and users' compliance decisions.
- **Check:** vcpkg.json without "license" (the PR workflow warns), values that aren't valid SPDX expressions, or a value contradicting upstream LICENSE/COPYING files.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: license](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#license); [untrustedPR workflow](https://github.com/microsoft/vcpkg/blob/master/.github/workflows/untrustedPR.yml); PRs: [#28032](https://github.com/microsoft/vcpkg/pull/28032#discussion_r1033088067), [#26506](https://github.com/microsoft/vcpkg/pull/26506#issuecomment-1226696130)

### MAN-006: Use lowercase letters, digits, and hyphens in port names

- **Rule:** A port's "name" must contain only lowercase ASCII letters, digits, and hyphens, must not start or end with a hyphen, and must equal its ports/<name> directory (clipper2, not Clipper2), because vcpkg parses it as an identifier and users type it.
- **Check:** Port directory or "name" with uppercase letters, underscores, dots, or leading/trailing hyphens, or a "name" that differs from the directory.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** [vcpkg.json reference: name](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#name); PRs: [#29303](https://github.com/microsoft/vcpkg/pull/29303#discussion_r1091553758)

### MAN-007: Write supports and platform with valid identifiers only

- **Rule:** "supports" and dependency or feature "platform" values must be platform expressions over vcpkg's identifiers (windows, linux, osx, uwp, mingw, android, static, staticcrt, x64, arm, native, ...) combined with !, &, |, and parentheses. Triplet names, capitalized OS names, and invented terms such as spirv are invalid; omit the field when the port or dependency applies everywhere.
- **Check:** Values such as Linux, x64-linux, x64-windows-static, or unknown words in "supports" or "platform", and expressions enumerating every platform instead of omitting the field.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: Platform expression](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#platform-expression); PRs: [#25142](https://github.com/microsoft/vcpkg/pull/25142#issuecomment-1151674990), [#28828](https://github.com/microsoft/vcpkg/pull/28828#discussion_r1065431469)

### MAN-008: Platform-qualify default features that don't build everywhere

- **Rule:** A default feature that can't build on every platform the port supports must appear in "default-features" as an object with a "platform" qualifier (e.g., {"name": "pe", "platform": "windows"}) and must actually work wherever it is enabled by default. Don't add the obsolete "platform-default-features" pseudo-feature workaround; unqualified defaults make the port uninstallable and untestable on those platforms.
- **Check:** Plain-string "default-features" entries naming features that have their own "supports" or platform-limited dependencies, features named platform-default-features, and ci.feature.baseline.txt entries marking a default feature as failing.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: default-features](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#default-features); PRs: [#53727](https://github.com/microsoft/vcpkg/pull/53727#issuecomment-5607882912), [#28862](https://github.com/microsoft/vcpkg/pull/28862#discussion_r1069059126)

### MAN-009: Depend on ports with default-features false and explicit features

- **Rule:** Port dependencies on ports that define default features should use `"default-features": false` and list every feature actually needed, because a plain dependency means dep[default] and forces those defaults on all consumers. The port must still build with only the listed features; a missing required feature blocks merge.
- **Check:** Dependencies written as plain strings, or objects with "features" but no `"default-features": false`, on ports that declare default features (gtk3, libjpeg-turbo, qtbase); compare required components (`find_package` COMPONENTS, Qt modules) with the declared features and build with those dependencies at [core] plus the listed features.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: dependency default-features](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#dependency-default-features); [vcpkg.json reference: default-features](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#default-features); PRs: [#49620](https://github.com/microsoft/vcpkg/pull/49620#issuecomment-3801337103), [#52561](https://github.com/microsoft/vcpkg/pull/52561#pullrequestreview-5594506771)

### MAN-010: Point homepage at the current official upstream location

- **Rule:** Every port should have a "homepage" URI (at least the source repository) pointing over https to the project's current official location, consistent with where the portfile downloads sources and never copied from another port. Update it when upstream moves (for example, to Codeberg) and never delete an existing homepage.
- **Check:** Missing "homepage"; http:// links or archived/moved pages; a homepage unrelated to the vcpkg_from_* REPO/URL; homepage or description identical to a sibling port's; hunks removing "homepage".
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: homepage](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#homepage); PRs: [#55151](https://github.com/microsoft/vcpkg/pull/55151#issuecomment-6996586642), [#51956](https://github.com/microsoft/vcpkg/pull/51956#discussion_r3307443713)

### MAN-011: Keep port and feature descriptions short and precise

- **Rule:** Port descriptions should be one or a few sentences that read well in a terminal, without marketing text; details belong in "homepage" or "documentation". Feature descriptions must state exactly what the feature does ("Use SDL3 backend.") and must not understate API-changing effects.
- **Check:** Multi-paragraph or promotional descriptions, and vague or misleading feature descriptions such as "Enable wide character support" for a switch that replaces the char API.
- **Severity:** advisory · **Scope:** all
- **Sources:** [PR review checklist c000003](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000003); PRs: [#36909](https://github.com/microsoft/vcpkg/pull/36909#discussion_r1503832474), [#22975](https://github.com/microsoft/vcpkg/pull/22975#discussion_r800497404)

### MAN-012: Keep supports expressions minimal and non-redundant

- **Rule:** Don't repeat port-level "supports" exclusions in feature-level "supports", and don't spell out subsets: windows already covers uwp, xbox, and mingw, so write "!windows", or "!windows | mingw" when only MSVC-style Windows is unsupported, instead of "!windows & !uwp & !xbox". Redundant terms make expressions harder to review and maintain.
- **Check:** Feature "supports" terms duplicating top-level exclusions, and !uwp or !xbox next to !windows.
- **Severity:** advisory · **Scope:** all
- **Sources:** [vcpkg.json reference: Platform expression](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#platform-expression); PRs: [#51301](https://github.com/microsoft/vcpkg/pull/51301#discussion_r3171518947), [#33246](https://github.com/microsoft/vcpkg/pull/33246#issuecomment-1706367521)

## SRC: Source acquisition

### SRC-001: Acquire everything in the portfile; forbid build-time downloads

- **Rule:** All sources, assets, and extra archives must be acquired in portfile.cmake through vcpkg's hash-checked download helpers, with dependencies taken from ports. Upstream configure or build steps that fetch content (FetchContent, CPM, ExternalProject, git clone, file(DOWNLOAD), NuGet restore, npm, cargo, "latest release" queries) must be disabled or patched out, and dropping such a patch is a regression. Hidden downloads bypass asset caching, offline builds, and reproducibility.
- **Check:** Grep upstream build files and patches for FetchContent_Declare, CPMAddPackage, ExternalProject_Add, file(DOWNLOAD, git clone, and nuget restore; look for downloads or "could not find git for clone" in configure/build logs and for deleted download-suppressing patches.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Troubleshoot: FetchContent dependency is not found](https://learn.microsoft.com/vcpkg/troubleshoot/build-failures#fetchcontent-dependency-is-not-found-during-build-process); [vcpkg_download_distfile](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_download_distfile); PRs: [#51368](https://github.com/microsoft/vcpkg/pull/51368#pullrequestreview-4194939426), [#38368](https://github.com/microsoft/vcpkg/pull/38368#discussion_r1764370390)

### SRC-002: Download from the official upstream location, not mirrors

- **Rule:** Fetch sources from the project's authoritative location (its official repository, release site, or an upstream-designated mirror) and follow upstream moves. Unofficial mirrors (github.com/mirror), third-party rehosts, servers not meant for mass automated downloads (snapshot.debian.org), and login- or registration-walled downloads are rejected; vcpkg doesn't rehost content, and a SHA512 prevents tampering but grants no redistribution rights.
- **Check:** Compare REPO/URLS hosts with the homepage's official download links; flag personal *-Mirror repositories, "thirdparty" path segments, organizations upstream doesn't own, distro snapshot hosts, and URLs that require login or EULA acceptance.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist c000008](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000008); PRs: [#25953](https://github.com/microsoft/vcpkg/pull/25953#issuecomment-1195753982), [#38161](https://github.com/microsoft/vcpkg/pull/38161#issuecomment-2073137818)

### SRC-003: Pin REF and every URL to immutable content

- **Rule:** REF must be a tag or full commit that exists in REPO and matches upstream's tag names, never a branch; every other download (patches, licenses, data) needs a URL pinned to a tag, commit, or release whose bytes never change. Avoid "latest" links, on-the-fly archives or diffs, FTP when HTTPS exists, package-manager self-updates, and VCPKG_USE_HEAD_VERSION, because an unedited port must rebuild identically.
- **Check:** Flag REF master/main/develop, URLS containing /refs/heads/, /master/, /main/, /HEAD/, latest, or ftp://, and VCPKG_USE_HEAD_VERSION in portfiles; open https://github.com/<REPO>/tree/<REF> or watch for 404 download errors to confirm REF exists.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_from_github: REF](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_from_github#ref); [PR review checklist c000005](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000005); PRs: [#47310](https://github.com/microsoft/vcpkg/pull/47310#discussion_r2345900441), [#52994](https://github.com/microsoft/vcpkg/pull/52994#pullrequestreview-4748204379)

### SRC-004: Update SHA512 with every download change

- **Rule:** Whenever a version, REF, or URL change alters downloaded content, update the matching SHA512 in the same change (set it to 0 and copy the hash from the error). Asset caches are keyed on SHA512, so a stale hash fails fresh builds or makes CI quietly test the old source.
- **Check:** Diffs that change "version", REF, or URLS but leave SHA512 untouched; "Expected hash ... Actual hash" or all-zero SHA512 failures; CI logs that still build the old source tree.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [vcpkg_from_github: SHA512](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_from_github#sha512); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#53603](https://github.com/microsoft/vcpkg/pull/53603#issuecomment-5456453004), [#42983](https://github.com/microsoft/vcpkg/pull/42983#issuecomment-3423324672)

### SRC-005: Use vcpkg download helpers, never file(DOWNLOAD)

- **Rule:** Every download in a portfile, helper script, or installed CMake file must use vcpkg_from_* or vcpkg_download_distfile with a SHA512, never CMake's file(DOWNLOAD), environment-variable or local source paths, or hand-written download and unpack steps. Extract additional archives with vcpkg_extract_source_archive(<out-var> ARCHIVE ... PATCHES ...). Only these helpers provide asset caching and hash verification.
- **Check:** Grep portfile.cmake, vcpkg-port-config.cmake, and installed config files for file(DOWNLOAD, $ENV{...} source paths, custom tar/unzip or file(ARCHIVE_EXTRACT steps, and vcpkg_extract_source_archive_ex or calls without ARCHIVE.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_download_distfile](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_download_distfile); [vcpkg_extract_source_archive](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_extract_source_archive); PRs: [#47310](https://github.com/microsoft/vcpkg/pull/47310#pullrequestreview-3214704030), [#40587](https://github.com/microsoft/vcpkg/pull/40587#discussion_r1732436883)

### SRC-006: Investigate SHA512 changes that keep the same version

- **Rule:** If a download's SHA512 changes while the version doesn't, diff the old and new sources before accepting it. When upstream re-tagged a release or a branch shares the tag's name, pin REF to the release's full commit and ask upstream to publish new tags instead of mutating them; when switching hosts or archive types, differing content must be handled as a version update.
- **Check:** Diffs that change only SHA512, or URLS/REPO without a version change; CI "unexpected hash" errors for tag archives; branches named like release tags; differences between the extracted old and new archives.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [vcpkg_from_github: REF](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_from_github#ref); [PR review checklist c000005](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000005); PRs: [#54674](https://github.com/microsoft/vcpkg/pull/54674#discussion_r4385732898), [#46667](https://github.com/microsoft/vcpkg/pull/46667#discussion_r2241695057)

### SRC-007: Use full, lowercase hex for commit REFs and hashes

- **Rule:** A commit REF must be the full 40-character commit ID, never an abbreviated hash, and SHA512 values and hexadecimal REFs must be lowercase. REF must identify one stable commit unambiguously, and tooling built on vcpkg may compare hex strings case-sensitively.
- **Check:** REF values of 7–39 hex characters and uppercase hex digits in SHA512 or REF arguments of vcpkg_from_* and vcpkg_download_distfile calls.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Use lowercase for hexadecimal digits strings](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#use-lowercase-for-hexadecimal-digits-strings); [vcpkg_from_github: REF](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_from_github#ref); PRs: [#38535](https://github.com/microsoft/vcpkg/pull/38535#discussion_r1598744620)

### SRC-008: Prefer forge helpers with HEAD_REF over vcpkg_from_git

- **Rule:** For sources on GitHub, GitLab, or Bitbucket, use the matching vcpkg_from_* helper with REF, SHA512, and HEAD_REF rather than vcpkg_from_git or vcpkg_download_distfile of the forge archive. Archive downloads are SHA512-verified and asset-cacheable while vcpkg_from_git output can't be asset cached, and HEAD_REF keeps --head builds working.
- **Check:** vcpkg_from_git with github.com or gitlab URLs; vcpkg_download_distfile of github.com/<owner>/<repo>/archive/... plus manual extraction; vcpkg_from_github, vcpkg_from_gitlab, or vcpkg_from_bitbucket calls without HEAD_REF.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_from_git](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_from_git); [vcpkg_from_github: HEAD_REF](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_from_github#head_ref); PRs: [#53603](https://github.com/microsoft/vcpkg/pull/53603#issuecomment-5456453004), [#38161](https://github.com/microsoft/vcpkg/pull/38161#issuecomment-2073137818)

### SRC-009: Give downloaded files port-specific FILENAMEs

- **Rule:** vcpkg_download_distfile FILENAME values must be attributable to the port and ideally its version (e.g., <port>-LICENSE, not LICENSE or v1.0.tar.gz), because all ports share one downloads directory and generic names collide.
- **Check:** FILENAME values such as LICENSE, COPYING, generic patch names, or bare version archives that lack the port name.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_download_distfile: FILENAME](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_download_distfile#filename); PRs: [#47310](https://github.com/microsoft/vcpkg/pull/47310#discussion_r2361529179)

### SRC-010: Prefer official release tarballs that ship generated files

- **Rule:** When upstream publishes official release tarballs containing generated files (configure scripts, generated sources), prefer them over forge tag archives that need autoreconf or other generators at build time. Tarballs and tag archives can differ in content, and not every project publishes tarballs.
- **Check:** Portfiles that run autoreconf or code generators, or add tool dependencies, only because the GitHub snapshot lacks files that upstream's dist tarball includes.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#45785](https://github.com/microsoft/vcpkg/pull/45785#issuecomment-2968342906), [#22201](https://github.com/microsoft/vcpkg/pull/22201#discussion_r869908992)

### SRC-011: Derive REF and download URLs from ${VERSION}

- **Rule:** Use the manifest's ${VERSION} in REF (e.g., "v${VERSION}"), URLs, and FILENAME instead of literal versions or duplicate variables, deriving other tag formats from it, so updates touch only the version and SHA512. If REF must temporarily deviate (e.g., a prerelease with needed fixes), comment why and when to restore it; upstream-generated Azure SDK ports are an accepted exception.
- **Check:** Literal version numbers in REF, URLS, or FILENAME; set(<NAME>_VERSION ...) duplicating vcpkg.json; REF literals that don't match the manifest version and lack an explaining comment.
- **Severity:** advisory · **Scope:** all
- **Sources:** [Update an existing port: Update the source reference](https://learn.microsoft.com/vcpkg/produce/update-package-version#update-the-source-reference); [Get started with packaging](https://learn.microsoft.com/vcpkg/get_started/get-started-packaging); [PR review checklist c000005](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000005); PRs: [#41150](https://github.com/microsoft/vcpkg/pull/41150#issuecomment-2384697944), [#27593](https://github.com/microsoft/vcpkg/pull/27593#discussion_r1012555130)

### SRC-012: Build every feature from the port's pinned sources

- **Rule:** Every feature must build from the same pinned `REF` and `SHA512` as the port. A feature must not fetch sources without a `REF` (which forces `--head`) or pin a different, older revision, because selecting a feature must never move users to other code.
- **Check:** Feature-conditional `vcpkg_from_*` calls with their own `REF` or no `REF`; the error "Package does not specify REF. It must be built using --head."; feature sources older than the port's version.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#27731](https://github.com/microsoft/vcpkg/pull/27731#issuecomment-1311165494), [#29046](https://github.com/microsoft/vcpkg/pull/29046#issuecomment-1406931721)

## PAT: Patches

### PAT-001: Report upstream-relevant patches upstream and link them

- **Rule:** Any patch that could be useful upstream (bug, compiler, platform, build-system, or export fixes) must be reported upstream as a PR, issue, or mailing-list post, linked in the PR and ideally beside its PATCHES entry, and carried until an upstream release contains it. Purely vcpkg-specific changes such as devendoring, install layout, or dependency wiring need no notification. Upstream owners are the final arbiters, and upstreamed fixes can later be dropped.
- **Check:** For each added or changed patch, classify hunks as generally useful or vcpkg-only and look for an upstream PR, issue, or commit link in the PR body or portfile. If it is missing, ask "Has this been submitted upstream?".
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Upstream notification and waiting periods](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#notify-upstream-owners-for-upstream-relevant-patches); [PR review checklist: c000007](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000007); PRs: [#47117](https://github.com/microsoft/vcpkg/pull/47117#discussion_r2309530245), [#54610](https://github.com/microsoft/vcpkg/pull/54610#issuecomment-6373693245)

### PAT-002: Wait for upstream acceptance before product-code patches

- **Rule:** Product-code or behavior patches not merged upstream land only after upstream was notified and either accepted them or let about 30 days pass without objection, in new ports too. High-confidence changes skip the wait: backports of merged commits, missing `#include`s, small obvious fixes, build-system-only packaging fixes, and disabling tests or examples. An explicit upstream "no" means vcpkg doesn't ship the change (users can overlay), because upstream owners are the final arbiters.
- **Check:** Classify hunks as build-system vs product logic (.c/.cpp/.h); product hunks need an upstream merge or a 30+-day-old unrejected submission. Read linked upstream threads for explicit rejections; a bug-tracker acknowledgement is not acceptance of the patch.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Upstream notification and waiting periods](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#notify-upstream-owners-for-upstream-relevant-patches); [Maintainer guide: Patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#patching); PRs: [#52281](https://github.com/microsoft/vcpkg/pull/52281#discussion_r3400054989), [#49167](https://github.com/microsoft/vcpkg/pull/49167#issuecomment-3702866530)

### PAT-003: Don't implement features or change upstream behavior in patches

- **Rule:** Patches and port-supplied build scripts exist for compatibility with compilers, platforms, libraries, and vcpkg's layout; they must not add functionality, APIs, options, bindings, or claimed language-standard support, nor change upstream defaults, public APIs, or dependency structure (including removing major dependencies upstream doesn't make optional) unless upstream endorses it. Wiring an option that already exists in product code into the build is fine. Such changes belong upstream; vcpkg is a packager, not the owner.
- **Check:** Patches adding source files, functions, options, or APIs without an upstream counterpart; hunks altering public headers, defaults, or dependency requirements. Be wary of patches presented as improvements or justified by "upstream won't take it".
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not implement features in patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-implement-features-in-patches); [PR review checklist: c000007](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000007); [CONTRIBUTING: New package guidelines](https://github.com/microsoft/vcpkg/blob/master/CONTRIBUTING.md); PRs: [#27317](https://github.com/microsoft/vcpkg/pull/27317#discussion_r1002353357), [#44939](https://github.com/microsoft/vcpkg/pull/44939#pullrequestreview-2777054148)

### PAT-004: Keep total patch volume minimal; update instead of patching

- **Rule:** vcpkg patches are the minimum change that unblocks users: reviewers judge total patch size (splitting into more files doesn't help) and reject large patch sets that can't be maintained across updates or risk license entanglement. Prefer targeted fixes over rewrites, and don't patch an outdated version when updating to a newer release would fix the issue; an upstream author should publish a release instead.
- **Check:** Diffstat of ports/<port>/*.patch and its growth per update; patches rewriting whole files or find modules; fixes already present in a newer upstream release.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Minimize patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#minimize-patches); [Maintainer guide: Patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#patching); PRs: [#42475](https://github.com/microsoft/vcpkg/pull/42475#issuecomment-2532852299), [#49864](https://github.com/microsoft/vcpkg/pull/49864#issuecomment-3874987421)

### PAT-005: Justify every patch and record its provenance

- **Rule:** Every patch must be needed to build or package the port and have a stated purpose: explain it in the PR, add a short comment beside its PATCHES entry linking the upstream PR, issue, or commit it comes from or was submitted as, and comment hunks whose context isn't obvious. Patches whose need can't be demonstrated are dropped, because updaters must know what each one fixes and when it can go.
- **Check:** New PATCHES entries without rationale or upstream link in the PR or portfile; "nice to have" hunks; warning-suppression patches that don't name the warnings or errors they address.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Minimize patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#minimize-patches); PRs: [#35781](https://github.com/microsoft/vcpkg/pull/35781#pullrequestreview-2020143755), [#43496](https://github.com/microsoft/vcpkg/pull/43496#discussion_r1931671335)

### PAT-006: Accept only patches maintainers can explain and verify

- **Rule:** Maintainers must be able to explain and vouch for every hunk: why it is the correct fix (not merely that it builds) and that it works on all supported compilers without new warnings. Prefer build-system workarounds (e.g., dropping `-Werror`) over product-code edits, reject unexplainable AI-generated or copied hunks and no-ops, and mark a target unsupported rather than patching code that can't build there. vcpkg owns its patches' consequences.
- **Check:** Product-code hunks without explanation, ABI or assembly edits nobody can justify, and no-op or never-compiled hunks. Look for new warnings or logic errors in patched code in MSVC, GCC, and Clang build logs.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#patching); PRs: [#51439](https://github.com/microsoft/vcpkg/pull/51439#pullrequestreview-4201335281), [#27307](https://github.com/microsoft/vcpkg/pull/27307#discussion_r999945581)

### PAT-007: Make every patch apply; refresh only failing ones

- **Rule:** Every patch must apply to the exact source being built; patch failures are fatal for pinned sources. On updates, refresh only patches that no longer apply, one at a time in a git-initialized source tree, regenerating them with `git diff` rather than hand-editing hunks. Leave still-applying patches untouched (no offset-only refreshes or hunks moved between files) and confirm no needed hunk was lost.
- **Check:** "Applying patch failed", "corrupt patch at line N", or "while searching for:" in build logs; patch diffs with only hunk-header or line-ending churn; hunks moved between, or missing from, renamed or merged patches.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); [vcpkg_extract_source_archive](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_extract_source_archive); PRs: [#48161](https://github.com/microsoft/vcpkg/pull/48161#issuecomment-3498869044), [#31281](https://github.com/microsoft/vcpkg/pull/31281#issuecomment-1537010202)

### PAT-008: Drop obsolete patches only after verifying the fix

- **Rule:** On updates, remove patches whose change the new upstream version already contains, delete their files, and explain each removal in the PR (e.g., link the upstream fix). First confirm upstream fixed the problem on every triplet and code path the patch covered; green CI isn't proof when CI doesn't exercise that path. Restore the patch if regressions appear, because dropping still-needed patches breaks users and dependents.
- **Check:** PATCHES entries whose change is already in the new sources; unreferenced patch files left in the port; removals without explanation; new dllexport, macro, or dependency-discovery failures after a removal.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** PRs: [#53272](https://github.com/microsoft/vcpkg/pull/53272#discussion_r3732704650), [#50387](https://github.com/microsoft/vcpkg/pull/50387#discussion_r2913394555)

### PAT-009: Reject patches adding unsafe code or vcpkg-specific search paths

- **Rule:** Patches must not add hazards such as calling-convention-changing casts, shared hard-coded temp paths, buffer sizes that no longer match, trusting the current directory, or loader and search-path changes that make libraries or tools look in vcpkg-specific or install-tree-relative locations for plugins, configs, or DLLs (keep a deterministic upstream or system default). Review the surrounding upstream code, not just the hunk. Such patches cause vulnerabilities, break relocation, or load incompatible binaries.
- **Check:** Function-pointer casts (e.g., to `LPTHREAD_START_ROUTINE`), fixed paths like `C:\Temp`, `OPENSSLDIR` or module dirs set to "." or install-tree paths, `os.add_dll_directory` or PATH tweaks, and stale `strcpy_s` sizes. Open the upstream file around each hunk.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#patching); PRs: [#53323](https://github.com/microsoft/vcpkg/pull/53323#pullrequestreview-4901272780), [#34009](https://github.com/microsoft/vcpkg/pull/34009#issuecomment-1760315969)

### PAT-010: Backport security fixes completely from merged upstream commits

- **Rule:** Security backports must come from commits upstream has merged (downloaded from commit-pinned URLs where possible), include every follow-up commit that corrects or completes the fix, and leave no related unsafe paths; patches taken from open upstream PRs get extra scrutiny. Prefer updating to an upstream release containing all fixes, and when unsure compare with what distributions such as Debian ship. Partial backports ship broken or still-vulnerable code.
- **Check:** CVE patches lacking upstream commit IDs or referencing unmerged PRs; upstream history after the fixing commit for follow-ups touching the same code; other security fixes missing since the packaged release.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [Maintainer guide: Prefer downloading approved patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#prefer-download-patches); PRs: [#52978](https://github.com/microsoft/vcpkg/pull/52978#issuecomment-5224497595), [#53208](https://github.com/microsoft/vcpkg/pull/53208#issuecomment-5209268465)

### PAT-011: Don't patch to keep abandoned code or dropped platforms alive

- **Rule:** vcpkg won't become a component's new maintainer: don't accept large product-code patches that keep archived or unresponsive upstreams (or their unmaintained dependents) building, or that restore platforms or functionality upstream removed (e.g., Windows 7); such ports are deindexed instead. A temporarily tolerated back-compat patch needs a committed owner and a portfile comment saying it will be removed, and must never revert upstream security fixes.
- **Check:** Hundreds of product-code lines against archived upstreams; patches reverting upstream platform drops or security changes; back-compat patches growing across updates without an owner or removal note.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Packaged components should be stable and actively maintained](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#packaged-projects-should-be-stable-and-actively-maintained); [Maintainer guide: Patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#patching); PRs: [#46758](https://github.com/microsoft/vcpkg/pull/46758#issuecomment-3161769640), [#42475](https://github.com/microsoft/vcpkg/pull/42475#issuecomment-2533370017)

### PAT-012: Change only necessary lines; disable code with constant conditions

- **Rule:** Patches touch only what is needed: no whitespace, blank-line, formatting, or renaming churn, commented-out code, added comments, or unused definitions. Disable code by making conditions constant (`AND FALSE`, `&& 0`) or wrapping regions in `if(0)`/`#if 0` rather than deleting lines; verbatim upstream backports may keep upstream's own changes. Small patches are easier to review and keep applying to new versions.
- **Check:** Hunks that vanish under `git diff -w`, reformatted or renamed code, upstream lines prefixed with `//` or `#`, and vcpkg commentary in patched sources. Flag long runs of deleted lines where a two-line guard would do.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Minimize patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#minimize-patches); PRs: [#46042](https://github.com/microsoft/vcpkg/pull/46042#discussion_r2153037552), [#36837](https://github.com/microsoft/vcpkg/pull/36837#discussion_r1503839424)

### PAT-013: Prefer configure options over patching, within reason

- **Rule:** If an option, cache variable, `CMAKE_DISABLE_FIND_PACKAGE_<Pkg>`, MSBuild `/p:` property, environment variable, or simple portfile step (e.g., `file(REMOVE)` of a vendored header) achieves the goal, use it instead of a patch, which must be refreshed every release. Stay reasonable: a one-line patch beats dozens of option lines, and don't override non-interface variables (e.g., `CMAKE_PROJECT_NAME`) just to avoid a clear patch.
- **Check:** Patches that only flip defaults, delete `find_package` calls, embed version numbers, or hard-code values that are `option()`s or cache variables. Conversely, flag `-D` overrides of project-identity variables.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Prefer options over patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#prefer-options-over-patching); PRs: [#44280](https://github.com/microsoft/vcpkg/pull/44280#discussion_r1986668977), [#31937](https://github.com/microsoft/vcpkg/pull/31937#issuecomment-1586221687)

### PAT-014: Patch dependency lookups at the find_package site

- **Rule:** First make upstream's existing lookup work (provide pkg-config, pass options). Otherwise patch only the lookup: use `find_package(<Pkg> [CONFIG] REQUIRED)` instead of hand-rolled `find_library` or SDK-variable logic, provide aliases or the variables the build expects (including `<Pkg>_FOUND`) instead of editing every use, and link imported targets with target-specific commands, never `include_directories`/`link_libraries` or raw library paths. This keeps patches small and usage requirements exported.
- **Check:** Patches rewriting many `${FOO_LIBRARIES}` uses, gutting Find modules, or swapping package names without `<Pkg>_FOUND`; `find_library(... zlib zdll)`, `$ENV{..._SDK}`, `include_directories(`, or `${Foo_LIBRARY}` file paths reaching exported targets.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Minimize patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#minimize-patches); PRs: [#51551](https://github.com/microsoft/vcpkg/pull/51551#discussion_r3190215818), [#41074](https://github.com/microsoft/vcpkg/pull/41074#discussion_r1767989552)

### PAT-015: Download merged upstream patches from commit-pinned URLs

- **Rule:** When a fix is merged or approved upstream, fetch it with `vcpkg_download_distfile` from a URL pinned to a full commit ID (append `?full_index=1` on GitHub/GitLab), with SHA512 and a descriptive FILENAME, instead of checking in a copy; this confirms upstream acceptance and keeps the repository small. Never use pull- or merge-request diff URLs, whose content changes, and take other distributions' patches (e.g., Debian) only from official pinned sources.
- **Check:** Checked-in patches identical to upstream commits or based on an unmerged variant of the fix; URLs containing `/pull/`, `/merge_requests/`, or patch-diff.githubusercontent.com, or lacking `?full_index=1`; distro patches copied into the port.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Prefer downloading approved patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#prefer-download-patches); PRs: [#24615](https://github.com/microsoft/vcpkg/pull/24615#issuecomment-1261494397), [#30123](https://github.com/microsoft/vcpkg/pull/30123#issuecomment-1464355473)

### PAT-016: Create patches with git diff --output and name them descriptively

- **Rule:** Generate patches as plain `git diff --output=<file>` output, not shell redirection (which re-encodes in PowerShell), without prose, `From:`/`Subject:` headers, or diffstat, and name them after what they fix (`fix-cmake-install.patch`, not `25.patch` or `patches.patch`); `.patch` and `.diff` are both fine. Hunks keep the target file's line endings (LF unless it is CRLF), and refreshed patches keep their existing endings, so diffs stay minimal.
- **Check:** Patch files with leading prose, commit headers, or "1 file changed" blocks; numeric or generic names; CRLF hunks against LF sources, or line-ending churn across a whole refreshed patch.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Patching example](https://learn.microsoft.com/vcpkg/examples/patching); [AGENTS.md](https://github.com/microsoft/vcpkg/blob/master/AGENTS.md); PRs: [#52423](https://github.com/microsoft/vcpkg/pull/52423#issuecomment-4748402988), [#41536](https://github.com/microsoft/vcpkg/pull/41536#discussion_r1800612960)

### PAT-017: Consolidate related changes into one patch per topic

- **Rule:** Put new changes for an existing concern (dependency lookup, static linkage, an export matching an import fix) into the existing patch for that concern instead of stacking another, never let one patch rewrite lines introduced by another, and don't mix unrelated topics into one large patch. Overlapping or topic-mixed patches are hard to review and to rebase on updates.
- **Check:** New patch files touching the same `find_package` or export logic as an existing patch; later patches modifying earlier patches' results; single patches spanning unrelated subsystems.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Minimize patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#minimize-patches); PRs: [#23624](https://github.com/microsoft/vcpkg/pull/23624#issuecomment-1072111157), [#33348](https://github.com/microsoft/vcpkg/pull/33348#pullrequestreview-1592744211)

### PAT-018: Don't patch build parts vcpkg doesn't use

- **Rule:** Don't carry hunks for code vcpkg disables or never runs: tests, examples, CPack or `make package`, an alternate build system such as meson in a CMake-built port, or code behind options the portfile turns off. Disable such parts with options, and if a patch is unavoidable remove only the minimal trigger (e.g., the `include(CPack)` line). These hunks add maintenance without changing what vcpkg installs.
- **Check:** Hunks touching test/ or examples/, CPack configuration, `meson.build` in a CMake-built port, or code behind options the portfile sets OFF.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Minimize patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#minimize-patches); [Maintainer guide: Do not build tests/docs/examples by default](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-build-testsdocsexamples-by-default); PRs: [#42695](https://github.com/microsoft/vcpkg/pull/42695#issuecomment-2543077391), [#51945](https://github.com/microsoft/vcpkg/pull/51945#discussion_r3335780034)

### PAT-019: Prefer patch files over scripted source edits

- **Rule:** Change upstream build scripts and sources with patch files, which fail loudly and can be upstreamed, rather than `vcpkg_replace_string` or `file(WRITE)` edits of `${SOURCE_PATH}`; those suit small vcpkg-specific fixups of installed files. Keep vcpkg-authored build files (e.g., a port-supplied CMakeLists.txt) as standalone files, not new-file hunks.
- **Check:** Multi-line `vcpkg_replace_string` on `${SOURCE_PATH}/CMakeLists.txt` or sources; several scripted edits of upstream files; patches creating a CMakeLists.txt from `/dev/null`.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Prefer patching over overriding VCPKG_<VARIABLE> values](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#prefer-patching-over-overriding-vcpkg_variable-values); PRs: [#28615](https://github.com/microsoft/vcpkg/pull/28615#discussion_r1058873514), [#47427](https://github.com/microsoft/vcpkg/pull/47427#pullrequestreview-3249412949)

### PAT-020: Apply patches and source edits unconditionally

- **Rule:** Prefer patches that apply for every triplet and host, selecting behavior inside the patch with preprocessor or build-system conditions, and list them literally under PATCHES; conditional patch lists, though supported, escape CI, break unnoticed on updates, and often mean the wrong file or source root is patched. Edits to the source tree after extraction (e.g., `vcpkg_replace_string` on `${SOURCE_PATH}`) must be unconditional to avoid surprises in editable mode.
- **Check:** `list(APPEND patches ...)` under `VCPKG_TARGET_IS_*`, `CMAKE_HOST_*`, or OS-release conditions; `PATCHES ${extra_patches}`; triplet- or feature-conditional edits under `${SOURCE_PATH}`.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_extract_source_archive](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_extract_source_archive); PRs: [#24913](https://github.com/microsoft/vcpkg/pull/24913#issuecomment-1138158490), [#26122](https://github.com/microsoft/vcpkg/pull/26122#discussion_r936437989)

### PAT-021: Fix defects in the port at fault, not in consumers

- **Rule:** When a dependency's exported usage requirements are wrong or missing (flags, link libraries, targets, .pc or CMake config content), fix that dependency's port, or the shared scripts for generic problems, instead of patching each consumer. Check whether a failure reflects a general upstream problem before adding a workaround validated by a single downstream. Consumer-side workarounds multiply and hide the real bug.
- **Check:** Consumer-port patches adding link libraries, definitions, or flags that belong to a dependency's interface; PRIVATE or BUILD_INTERFACE tricks hiding information dependents need; workarounds justified by one downstream.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#32744](https://github.com/microsoft/vcpkg/pull/32744#issuecomment-1655318838), [#29257](https://github.com/microsoft/vcpkg/pull/29257#discussion_r1093973721)

### PAT-022: Remove upstream version checks instead of bumping them

- **Rule:** When an upstream minimum-version check on a dependency or tool (e.g., `find_package(X 15 REQUIRED)` or a version comparison) blocks the build, patch the check out or leave it as upstream wants; don't replace one hard-coded version with another. In vcpkg, vcpkg.json and the baseline govern versions, and a new hard-coded minimum can break users who select other versions.
- **Check:** Patches changing version numbers in `find_package`, `pkg_check_modules`, or comparison checks instead of removing them.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Version constraints in ports](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#version-constraints-in-ports); PRs: [#42294](https://github.com/microsoft/vcpkg/pull/42294#issuecomment-2499022844), [#51932](https://github.com/microsoft/vcpkg/pull/51932#issuecomment-4532216886)

### PAT-023: Don't detect vcpkg in patches; use real options

- **Rule:** Patches must not switch behavior by detecting vcpkg (`CMAKE_TOOLCHAIN_FILE MATCHES "vcpkg"`, `VCPKG_TOOLCHAIN`, `VCPKG_TARGET_TRIPLET`); condition logic on the real build inputs (`BUILD_SHARED_LIBS`, `USE_INCLUDED_*` options, static linkage) or add a proper option that the portfile sets. vcpkg detection isn't upstreamable and ignores the conditions that actually matter.
- **Check:** Grep patches and port-supplied CMake files for `CMAKE_TOOLCHAIN_FILE MATCHES`, `if(VCPKG_TOOLCHAIN)`, `DEFINED VCPKG_`, or "vcpkg" string comparisons.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#45419](https://github.com/microsoft/vcpkg/pull/45419#discussion_r2079032544), [#39886](https://github.com/microsoft/vcpkg/pull/39886#discussion_r1694207587)

## PF: Portfile authoring

### PF-001: Don't use the deprecated vcpkg CMake helpers

- **Rule:** Use `vcpkg_cmake_configure`, `vcpkg_cmake_build`, `vcpkg_cmake_install`, and `vcpkg_cmake_config_fixup`, adding `vcpkg-cmake`/`vcpkg-cmake-config` as `"host": true` dependencies, never `vcpkg_configure_cmake`, `vcpkg_build_cmake`, `vcpkg_install_cmake`, or `vcpkg_fixup_cmake_targets`; drop `PREFER_NINJA` when migrating. The PR workflow reports the legacy functions as forbidden, and the replacements live in versioned helper ports whose behavior can be pinned.
- **Check:** Grep changed portfiles for the four legacy names and `PREFER_NINJA`, and vcpkg.json for the host helper dependencies. Look for the workflow's deprecated-function error annotations.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Avoid deprecated helper functions](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-deprecated-helper-functions); [PR review checklist: c000001](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000001); [untrustedPR workflow](https://github.com/microsoft/vcpkg/blob/master/.github/workflows/untrustedPR.yml); PRs: [#31080](https://github.com/microsoft/vcpkg/pull/31080#issuecomment-1521038998), [#38712](https://github.com/microsoft/vcpkg/pull/38712#issuecomment-2112180645)

### PF-002: Base platform logic on triplet variables, never triplet names

- **Rule:** Portfiles run in CMake script mode: base target decisions on `VCPKG_TARGET_IS_<OS>`, `VCPKG_TARGET_ARCHITECTURE`, `VCPKG_LIBRARY_LINKAGE`, and `VCPKG_CROSSCOMPILING`, and host decisions (e.g., which tool binary to download) on `CMAKE_HOST_*` or `VCPKG_HOST_IS_*`. Never use project-mode variables (`WIN32`, `MSVC`, `APPLE`, `CMAKE_SYSTEM_NAME`, `CMAKE_CROSSCOMPILING`) or triplet names, which users choose freely. `VCPKG_TARGET_IS_WINDOWS` also covers UWP and MinGW.
- **Check:** Grep portfile.cmake for `if(WIN32`, `MSVC`, `MINGW`, `APPLE`, `CMAKE_SYSTEM_NAME`, `CMAKE_CROSSCOMPILING`, and `TARGET_TRIPLET MATCHES`/`STREQUAL`. Also flag target variables choosing host tools and misspelled `VCPKG_*` names that silently disable blocks.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Portfiles are run in Script Mode](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#portfiles-are-run-in-script-mode); [Portfile variables: VCPKG_TARGET_IS_<system>](https://learn.microsoft.com/vcpkg/maintainers/variables#vcpkg_target_is_system); PRs: [#46136](https://github.com/microsoft/vcpkg/pull/46136#discussion_r2161971075), [#34546](https://github.com/microsoft/vcpkg/pull/34546#issuecomment-2045645999)

### PF-003: Use LF line endings and clean whitespace in port files

- **Rule:** Non-patch files a PR adds or touches (portfile.cmake, vcpkg.json, usage, port-supplied CMakeLists and sources, test ports) must use LF line endings, have no trailing whitespace, and end with a newline, without doubled blank lines. The PR workflow checks every non-patch file of a touched port, including pre-existing problems. Don't convert whole files between LF and CRLF or add `* text=auto` to .gitattributes as a workaround.
- **Check:** Workflow "Incorrect whitespace" errors and annotations; `git diff --check` warnings; "\ No newline at end of file"; whole-file diffs caused by line-ending conversion.
- **Severity:** blocking · **Scope:** all
- **Sources:** [untrustedPR workflow](https://github.com/microsoft/vcpkg/blob/master/.github/workflows/untrustedPR.yml); PRs: [#50045](https://github.com/microsoft/vcpkg/pull/50045#discussion_r2818720299), [#53854](https://github.com/microsoft/vcpkg/pull/53854#discussion_r3976556650)

### PF-004: Make every vcpkg_replace_string call change something

- **Rule:** Each `vcpkg_replace_string` must modify its file, because silent non-matches hide breakage (no-op replacements fail in CI). Guard configuration-specific replacements of installed files with the real condition or narrow the file selection instead of adding `IGNORE_UNCHANGED`, which is reserved for cases where all inputs are known but the condition is impractical; re-verify patterns on updates. Use `vcpkg_replace_string(... REGEX)` instead of manual `file(READ)`/`string(REGEX REPLACE)`/`file(WRITE)` sequences.
- **Check:** `IGNORE_UNCHANGED` in the diff; "vcpkg_replace_string made no changes" in logs; replacements looping over broad globs; manual read/replace/write sequences.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_replace_string: IGNORE_UNCHANGED](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_replace_string#ignore_unchanged); [vcpkg_replace_string: REGEX](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_replace_string#regex); PRs: [#45187](https://github.com/microsoft/vcpkg/pull/45187#discussion_r2055460604), [#34719](https://github.com/microsoft/vcpkg/pull/34719#issuecomment-1779895689)

### PF-005: Make post-install steps work for every triplet and build type

- **Rule:** Post-install edits (`vcpkg_replace_string`, `file(READ/WRITE/REMOVE)`, `vcpkg_copy_tools`) may only target files that exist for the current triplet, linkage, and build type. `VCPKG_BUILD_TYPE` is either empty (debug and release) or `release`: guard debug-tree steps with `if(NOT VCPKG_BUILD_TYPE)` and never test for `debug`. Otherwise release-only, static, or non-Windows builds fail.
- **Check:** Unconditional access to `${CURRENT_PACKAGES_DIR}/debug/...`, `bin/*-config`, or linkage-specific headers and .pc files; `VCPKG_BUILD_TYPE STREQUAL "debug"`; logs with "file failed to open for reading" or "Couldn't find tool".
- **Severity:** blocking · **Scope:** all
- **Sources:** [Triplet variables: VCPKG_BUILD_TYPE](https://learn.microsoft.com/vcpkg/users/triplets#vcpkg_build_type); PRs: [#39561](https://github.com/microsoft/vcpkg/pull/39561#discussion_r1660552957), [#28181](https://github.com/microsoft/vcpkg/pull/28181#discussion_r1058283490)

### PF-006: Pass only effective options; justify MAYBE_UNUSED_VARIABLES

- **Rule:** Every `-D` option must be read by upstream and take effect. When configure reports unused variables, remove options upstream dropped or overwrites (with their features and dependencies), duplicates of upstream defaults, and values overriding `FEATURE_OPTIONS`, patching the build if the effect is still needed; list a variable under `MAYBE_UNUSED_VARIABLES` only if it applies to some configuration, with a comment saying when. Dead options hide misspellings and bugs.
- **Check:** Configure-log "The following variables are not used in CMakeLists.txt"; uncommented or never-applicable `MAYBE_UNUSED_VARIABLES` entries; options checked against the new upstream sources, including the name upstream reads (e.g., `PERL_EXECUTABLE`, not `PERL`). Pre-existing dead options may go to a separate cleanup.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: MAYBE_UNUSED_VARIABLES must apply](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#variables-in-maybe_unused_variables-must-apply-to-at-least-one-configuration); [vcpkg_cmake_configure: MAYBE_UNUSED_VARIABLES](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_cmake_configure#maybe_unused_variables); PRs: [#53115](https://github.com/microsoft/vcpkg/pull/53115#discussion_r3687067647), [#52834](https://github.com/microsoft/vcpkg/pull/52834#discussion_r3762347688)

### PF-007: Reference only declared features; keep feature options boolean

- **Rule:** Every feature name tested in portfile.cmake (`FEATURES`/`INVERTED_FEATURES` entries, `"<f>" IN_LIST FEATURES`) must be declared in vcpkg.json. `vcpkg_check_features` only produces boolean `-D<VAR>=ON/OFF`, so never use it to inject flags or values, and never parse `FEATURE_OPTIONS`; test feature state with `IN_LIST FEATURES` and add definitions through options or `CMAKE_PROJECT_INCLUDE`. Misnamed or misused checks silently disable advertised features.
- **Check:** Compare feature names in portfile.cmake with vcpkg.json; `vcpkg_check_features` entries containing `=`; `if(FEATURE_OPTIONS MATCHES ...)`. Build `port[feature]` and confirm the mapped option is ON in configure logs.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_check_features: Usage](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_check_features#usage); PRs: [#53687](https://github.com/microsoft/vcpkg/pull/53687#pullrequestreview-5067000069), [#35157](https://github.com/microsoft/vcpkg/pull/35157#discussion_r1397908149)

### PF-008: Quote arguments that expand variables

- **Rule:** Double-quote every argument containing `${...}`, especially paths (`"${SOURCE_PATH}"`, `"${CURRENT_PACKAGES_DIR}/share/${PORT}"`) and whole options (`"-DFOO=${BAR}"`, never `-DFOO="${BAR}"`, whose inner quotes become part of the value); leave list splats such as `${FEATURE_OPTIONS}` unquoted. In `if()` comparisons quote both variables and literals (`if("${x}" STREQUAL "y")`). Unquoted values split on spaces and semicolons, and `if()` dereferences bare names.
- **Check:** Unquoted `${SOURCE_PATH}`, `${CURRENT_PACKAGES_DIR}`, or `${CMAKE_CURRENT_LIST_DIR}` arguments in `file()`, `configure_file()`, and `vcpkg_*` calls; `-DVAR="..."` options; `if(${var} STREQUAL ...)`.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [CMake guidelines](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#the-guidelines); PRs: [#31037](https://github.com/microsoft/vcpkg/pull/31037#discussion_r1177371032), [#40327](https://github.com/microsoft/vcpkg/pull/40327#discussion_r1708785735)

### PF-009: Replace other deprecated or removed portfile helpers

- **Rule:** Replace `vcpkg_extract_source_archive_ex` and the non-ARCHIVE overload with `vcpkg_extract_source_archive(<out> ARCHIVE ...)`, `vcpkg_apply_patches` with PATCHES, `vcpkg_build_msbuild`/`vcpkg_install_msbuild` with `vcpkg_msbuild_install` (vcpkg-msbuild), `vcpkg_configure_gn`/`vcpkg_install_gn` with vcpkg-gn, and `vcpkg_fail_port_install` with `supports`; delete `include(vcpkg_common_functions)` and `vcpkg_test_cmake()`. New code must not use these or helper options reported as deprecated; unchanged inherited calls don't block an update.
- **Check:** Grep for these names and deprecated options (e.g., `ADDITIONAL_NATIVE_BINARIES`); workflow deprecation warnings; back-compat messages, which are fatal in CI for removed functions.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Avoid deprecated helper functions](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-deprecated-helper-functions); [PR review checklist: c000001](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000001); [vcpkg_install_msbuild](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_install_msbuild); PRs: [#39886](https://github.com/microsoft/vcpkg/pull/39886#discussion_r1690724492), [#54258](https://github.com/microsoft/vcpkg/pull/54258#pullrequestreview-5399555366)

### PF-010: Map features with the canonical vcpkg_check_features pattern

- **Rule:** In CMake ports, translate features into options with `vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES <feature> <OPTION> ... INVERTED_FEATURES ...)`, one pair per line, passing `${FEATURE_OPTIONS}` and mapping one feature to several options when needed. Don't build options from `if(... IN_LIST FEATURES) set(...)` chains, loops over `ALL_FEATURES`, or intermediate variables, and don't also hard-code options a feature controls. The canonical pattern keeps the mapping explicit and reviewable.
- **Check:** `if("<f>" IN_LIST FEATURES)` chains feeding `-D<X>=${<X>}`; `foreach(... ALL_FEATURES)` synthesizing `-DWITH_*`; options present both in the feature mapping and hard-coded.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_check_features](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_check_features); PRs: [#38674](https://github.com/microsoft/vcpkg/pull/38674#discussion_r1602239327), [#27608](https://github.com/microsoft/vcpkg/pull/27608#pullrequestreview-1167735930)

### PF-011: Announce system dependencies early, without distro detection

- **Rule:** When a port needs libraries or tools vcpkg doesn't provide, print a `message()` near the top of portfile.cmake, before heavy work, naming them and how to obtain them so users can stop early. List only what vcpkg can't provide, don't assume apt on macOS or other hosts, and don't detect the Linux distribution (e.g., reading /etc/os-release) or emit per-distro instructions; per-port distro logic doesn't scale.
- **Check:** Ports failing on clean hosts for missing autoconf-archive, xcb, or similar with no early message; messages listing vcpkg-provided ports or only apt commands for macOS-capable ports; reads of /etc/os-release.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [PR review checklist: c000012](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000012); PRs: [#26336](https://github.com/microsoft/vcpkg/pull/26336#issuecomment-1221014229), [#44830](https://github.com/microsoft/vcpkg/pull/44830#discussion_r2097164237)

### PF-012: Remove boilerplate comments, debug output, and dead code

- **Rule:** Before submitting, delete `vcpkg create` template comments (e.g., `# <--- The tag/commit...`), comments that restate code, diagnostic `message()` prints, commented-out code, and redundant statements; delete unneeded code rather than commenting it out. Portfiles should be short and declarative, and leftover noise obscures what the port does.
- **Check:** Template comment blocks or `# <---` scaffold remarks; debug `message(STATUS ...)` prints; commented-out `vcpkg_replace_string` or `file()` blocks; duplicated cleanup lines.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Avoid excessive comments in portfiles](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-excessive-comments-in-portfiles); [PR review checklist: c000004](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000004); PRs: [#45146](https://github.com/microsoft/vcpkg/pull/45146#discussion_r2052051753), [#48738](https://github.com/microsoft/vcpkg/pull/48738#discussion_r2613324039)

### PF-013: Decide installed content from features, not if(EXISTS)

- **Rule:** Decide what to copy, move, or delete from FEATURES, triplet variables, or explicit build options rather than `if(EXISTS ...)` probes of what the build happened to produce, taking control of the build so outputs are deterministic. Existence checks hide missing control and let results differ between machines or binary-cache reuse; exceptions for genuinely optional outputs are rare.
- **Check:** `if(EXISTS "${CURRENT_PACKAGES_DIR}/...")` or buildtree existence checks guarding `file(COPY/RENAME/REMOVE)` or `vcpkg_copy_tools`. Ask which feature or option determines the file.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#24758](https://github.com/microsoft/vcpkg/pull/24758#discussion_r882648328), [#22775](https://github.com/microsoft/vcpkg/pull/22775#discussion_r791356215)

### PF-014: Use vcpkg helpers instead of raw commands; fail on errors

- **Rule:** Drive builds through vcpkg's helpers (`vcpkg_cmake_*`, `vcpkg_make_*` from vcpkg-make, and the meson and MSBuild helpers) rather than hand-run configure, make, or ninja, so the triplet's toolchain and flags apply; fix autotools ports by moving to vcpkg-make, not by adding workarounds atop the frozen `vcpkg_configure_make`. Run other commands with `vcpkg_execute_required_process`; raw `execute_process` needs `COMMAND_ERROR_IS_FATAL ANY` or a checked `RESULT_VARIABLE`, plus `OUTPUT_STRIP_TRAILING_WHITESPACE` for captured values.
- **Check:** Portfiles running `configure`, `make`, or `ninja` through `vcpkg_execute_*` or `execute_process` with hand-assembled flags; bare `execute_process(` without error handling in portfiles, helper ports, or installed config files.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [CONTRIBUTING: New package guidelines](https://github.com/microsoft/vcpkg/blob/master/CONTRIBUTING.md); [vcpkg_make_configure](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_make_configure); PRs: [#28773](https://github.com/microsoft/vcpkg/pull/28773#discussion_r1103292223), [#49703](https://github.com/microsoft/vcpkg/pull/49703#issuecomment-3823648877)

### PF-015: Let vcpkg_cmake_configure set BUILD_SHARED_LIBS

- **Rule:** `vcpkg_cmake_configure` already passes `BUILD_SHARED_LIBS` matching the triplet, so don't set or pass it. Derive project-specific shared/static switches from `VCPKG_LIBRARY_LINKAGE` (never `VCPKG_CRT_LINKAGE`) with `string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" <var>)` rather than set/if blocks or ON/OFF comparisons. Redundant or wrong mappings make the build ignore or contradict the triplet.
- **Check:** `-DBUILD_SHARED_LIBS=` or `set(BUILD_SHARED_LIBS ...)` in portfile.cmake; linkage options tied to `VCPKG_CRT_LINKAGE` or compared with ON/OFF; multi-line set/if blocks computing linkage flags.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Choose either static or shared binaries](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#only-static-or-shared); PRs: [#27233](https://github.com/microsoft/vcpkg/pull/27233#discussion_r996986234), [#38874](https://github.com/microsoft/vcpkg/pull/38874#discussion_r1610473205)

### PF-016: Collect options in lists and call each helper once

- **Rule:** Build option lists with `vcpkg_list(SET options)` plus conditional `list(APPEND options ...)`, each `-D` option a separate list element, and make one `vcpkg_cmake_configure`, `vcpkg_from_*`, or extract call instead of duplicating calls per platform. Don't create a variable per option or concatenate options into one string (`"-DA=1 -DB=2"` becomes a single malformed argument). Duplicated calls duplicate every option to maintain.
- **Check:** Configure or extract calls repeated in if/else branches; `set(x "-DA=ON -DB=OFF")` followed by `OPTIONS ${x}`; `string(APPEND opts ...)`; per-option `set(with-x ...)` variables.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [CMake guidelines](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#the-guidelines); PRs: [#37157](https://github.com/microsoft/vcpkg/pull/37157#discussion_r1517128020), [#31739](https://github.com/microsoft/vcpkg/pull/31739#discussion_r1212174451)

### PF-017: Follow the conventional post-install step order

- **Rule:** Run install and fixups once, in the conventional order: install (e.g., `vcpkg_cmake_install`), `vcpkg_copy_pdbs` after any rearranging of binaries (it isn't implicit), `vcpkg_cmake_config_fixup`, `vcpkg_fixup_pkgconfig`, cleanup such as removing debug/include, usage, then `vcpkg_install_copyright`. Don't repeat or scatter cleanup steps. PDBs can only be matched to installed binaries, and a predictable order keeps portfiles reviewable.
- **Check:** `vcpkg_copy_pdbs` before the install step or missing in DLL-capable ports; repeated or scattered `file(REMOVE_RECURSE ...)` lines; fixups out of order.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_copy_pdbs: Notes](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_copy_pdbs#notes); PRs: [#46951](https://github.com/microsoft/vcpkg/pull/46951#discussion_r2296075639), [#39886](https://github.com/microsoft/vcpkg/pull/39886#discussion_r1690730913)

### PF-018: Keep portfiles short, linear, and declarative

- **Rule:** Write portfiles as simple linear steps using standard helpers, not helper-function frameworks, immediately invoked functions, custom parsers of upstream option files, or deeply nested branching. Derive repeated data (URLs, file names, embedded version strings) from `${VERSION}` instead of per-update tables or hand-edited files, use `file(RENAME)` rather than copy-then-delete, and skip compiler builds when a port only runs a generator or copies files. Simple ports are easier to review and maintain.
- **Check:** Portfiles defining many functions or macros or port-local .cmake libraries; per-component tables repeating patterns; port files containing the literal current version; copy-then-remove sequences; configure/build steps that only wrap generation or copying.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Avoid excessive comments in portfiles](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-excessive-comments-in-portfiles); PRs: [#47427](https://github.com/microsoft/vcpkg/pull/47427#issuecomment-3329859654), [#50188](https://github.com/microsoft/vcpkg/pull/50188#issuecomment-4565633599)

### PF-019: Comment non-obvious workarounds where they live

- **Rule:** Options, patches, or code that exist for a non-obvious reason (e.g., empty install dirs that disable components, an option that looks optional but is required, a temporary exception slated for removal) need a short portfile comment saying what breaks without them; the PR description isn't enough, since the next maintainer may otherwise remove something load-bearing. Port-specific intricacies belong in portfile comments, not usage text.
- **Check:** Unexplained odd options (e.g., `-DEXAMPLEDIR=`), special cases, or temporary exceptions without a comment; comments that misdescribe load-bearing settings.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#47347](https://github.com/microsoft/vcpkg/pull/47347#discussion_r2350467662), [#24587](https://github.com/microsoft/vcpkg/pull/24587#discussion_r869904438)

### PF-020: Don't resolve dependency libraries or toolchain details in portfiles

- **Rule:** Portfiles have no toolchain or target context, so don't locate dependency libraries with `find_library`/`find_path` and pass the results into the build, and avoid `vcpkg_cmake_get_vars` in regular ports (if unavoidable, use `VCPKG_COMBINED_*` flags rather than raw `VCPKG_DETECTED_*`). Let dependencies' exported CMake configs or pkg-config files carry usage requirements; hard-coded results break across triplets and lose transitive requirements.
- **Check:** `find_library`/`find_path` against `CURRENT_INSTALLED_DIR` in portfile.cmake; hard-coded library-name lists for other ports; `vcpkg_cmake_get_vars` in non-helper ports.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Portfiles are run in Script Mode](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#portfiles-are-run-in-script-mode); [vcpkg_cmake_get_vars](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_cmake_get_vars); PRs: [#25652](https://github.com/microsoft/vcpkg/pull/25652#discussion_r921820405)

### PF-021: Fail clearly on unexpected setups and explain surprising choices

- **Rule:** End architecture or version dispatch with one if/elseif chain whose `else()` raises `message(FATAL_ERROR ...)`, and check required external tools up front with an actionable error. Explain surprising choices (forced backend, DLL needed under a static triplet, no windowing support) with a concise `message(STATUS|WARNING)` on how to change them, e.g., via an overlay port, and use `vcpkg_buildpath_length_warning(<N>)` instead of a hard path-length error. Users then get actionable feedback, not obscure failures.
- **Check:** Dispatch chains without an else branch or repeated independent ifs on one variable; tools used without an existence check; forced options without any message; path-length FATAL_ERRORs or CI baseline entries.
- **Severity:** advisory · **Scope:** all
- **Sources:** [Maintainer guide: Recommended solutions](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#recommended-solutions); [vcpkg_buildpath_length_warning](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_buildpath_length_warning); PRs: [#21281](https://github.com/microsoft/vcpkg/pull/21281#discussion_r831420140), [#45873](https://github.com/microsoft/vcpkg/pull/45873#discussion_r2136650422)

### PF-022: Follow portfile formatting and naming conventions

- **Rule:** Put each helper keyword on its own line with values indented beneath (`PATCHES` alone, then one patch per line), indent with four spaces rather than tabs, and keep the standard layout of `vcpkg_from_*` blocks. Use `${PORT}` rather than the literal port name in paths such as `share/${PORT}`, lowercase names for new local variables, and no gratuitous renames or reformatting of untouched lines. Consistent layout keeps ports readable and diffs small.
- **Check:** Several patches or options on one line; tabs or misaligned argument blocks; `share/<literal-name>` paths; new UPPERCASE local variables or pure renames in the diff.
- **Severity:** advisory · **Scope:** all
- **Sources:** [CMake guidelines: Naming variables](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#naming-variables); PRs: [#29236](https://github.com/microsoft/vcpkg/pull/29236#discussion_r1089851473), [#24998](https://github.com/microsoft/vcpkg/pull/24998#discussion_r886187698)

### PF-023: Don't commit binary files to the repository

- **Rule:** Don't check binary blobs such as archives, executables, libraries, or crafted test inputs into `ports/`, `scripts/`, or `triplets/`. Build test inputs from sources or download them with a verified hash, even if the port becomes more complex.
- **Check:** Diffs adding `.zip`, `.tar.*`, `.exe`, `.dll`, `.lib`, `.a`, `.bin`, or other non-text files.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#45524](https://github.com/microsoft/vcpkg/pull/45524#issuecomment-2968356891)

### PF-024: Keep copied upstream code and maintainer notes out of port directories

- **Rule:** Don't check large amounts of upstream-derived code (copied sources or converted build files) into a port directory. Generate them at build time or use a small patch, because copied code risks license entanglement with the vcpkg repository. Don't add maintainer-only notes or status files (for example `vulnerabilities.md`) to ports.
- **Check:** Port directories gaining large copied source or build files, conversion scripts, or Markdown notes that the portfile doesn't use.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#patching); PRs: [#27444](https://github.com/microsoft/vcpkg/pull/27444#issuecomment-1302642445), [#34235](https://github.com/microsoft/vcpkg/pull/34235#issuecomment-1745276116)

## DEP: Dependencies and features

### DEP-001: Resolve every optional dependency in exactly one way

- **Rule:** Every dependency the upstream build can discover (non-REQUIRED `find_package`, pkg-config, header or library checks, `find_program` tools, Threads/OpenMP, test-only probes) must be either declared in vcpkg.json (core or feature) and required, or explicitly disabled; dependencies without a port are disabled. Ports need not expose every knob, and choices upstream already fixes need no repetition. Otherwise the package depends on what happens to be installed, breaking binary caching.
- **Check:** Grep upstream build files for non-REQUIRED probes and `if(<X>_FOUND)` branches and compare them with vcpkg.json and portfile options (`CMAKE_DISABLE_FIND_PACKAGE_<Pkg>`, `CMAKE_REQUIRE_FIND_PACKAGE_<Pkg>`, `VCPKG_LOCK_FIND_PACKAGE_<Pkg>`, `-DWITH_X=OFF`). Flag configure-log "Found X" lines for undeclared packages and `file(REMOVE)` of optional components instead of disabling them.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Explicitly control dependencies](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#when-defining-features-explicitly-control-dependencies); [Maintainer guide: Ports must not be path dependent](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-not-be-path-dependent); PRs: [#46711](https://github.com/microsoft/vcpkg/pull/46711#pullrequestreview-3367951368), [#50282](https://github.com/microsoft/vcpkg/pull/50282#pullrequestreview-3891241310)

### DEP-002: Build against vcpkg ports, not vendored copies

- **Rule:** Don't compile or install bundled copies of libraries vcpkg packages (third_party trees, submodules, single-file copies, forks); depend on the port via upstream's system-library option or a patch, adding missing ports first. A remaining copy (e.g., upstream-modified) needs a portfile comment and declared license and must not reach consumers' link domain (ODR violations) or include tree, else the port risks deindexing. Pre-existing vendoring in unrelated updates is a follow-up.
- **Check:** Look for compiled `third_party/`, `external/` or submodule sources, `*_USE_SYSTEM_*`/`*_BUNDLED_*` options left bundled, and installed headers or exported symbols (nm/dumpbin) of other projects. Port-specific generated code (glad loaders, protoc output) is not vendoring.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not use vendored dependencies](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-use-vendored-dependencies); [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); PRs: [#52782](https://github.com/microsoft/vcpkg/pull/52782#pullrequestreview-4658434354), [#54516](https://github.com/microsoft/vcpkg/pull/54516#issuecomment-6323056900)

### DEP-003: Keep features additive; never model alternatives as features

- **Rule:** Features must be additive: whenever `port[a]` and `port[b]` install, `port[a,b]` must install and serve consumers of both, and ports must build when dependencies have extra features enabled. Never use features to choose among mutually exclusive backends, providers, or implementations (TLS, mysql vs mariadb); pick one canonical configuration, since vcpkg unions requested features and cannot keep one off. Existing alternative features are grandfathered; new exceptions need a maintainer-team decision.
- **Check:** Look for if/elseif backend selection over `FEATURES`, `FATAL_ERROR` on feature combinations, "instead of"/"mutually exclusive" descriptions, features taking over another port's `find_package` (libressl for OpenSSL), new `options` entries in ci.feature.baseline.txt, and upstream aborting on dependency variants (`hdf5[parallel]`). Coexisting runtime-selectable backends are additive.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not use features to implement alternatives](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-use-features-to-implement-alternatives); [Features concept](https://learn.microsoft.com/vcpkg/concepts/features#features); PRs: [#47600](https://github.com/microsoft/vcpkg/pull/47600#issuecomment-3417107418), [#37233](https://github.com/microsoft/vcpkg/pull/37233#discussion_r1517210946)

### DEP-004: Let default features add behavior, never APIs

- **Rule:** Add a default feature only when the library is not reasonably functional without it and the feature only adds behavior behind existing APIs (extra codecs, compressors); never default-enable new headers, targets, tools, codegen, tests, optional integrations, or things users may need off. Upstream defaults are no justification, and anything always required is enabled unconditionally in the portfile. Default features are effectively mandatory because every dependent must opt out.
- **Check:** Inspect `default-features` additions: for each entry, check what it installs (headers, libraries, targets, executables = API), whether it flips public macros or pulls heavy dependencies, and whether it is supported on all of the port's platforms.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Default features enable behaviors, not APIs](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#default-features-should-enable-behaviors-not-apis); [Default features: role](https://learn.microsoft.com/vcpkg/concepts/default-features#role-of-default-features); PRs: [#43108](https://github.com/microsoft/vcpkg/pull/43108#discussion_r1940541039), [#51919](https://github.com/microsoft/vcpkg/pull/51919#discussion_r3306554333)

### DEP-005: Wire every feature to explicit ON/OFF build switches

- **Rule:** Map every vcpkg.json feature in the portfile (`vcpkg_check_features` or `IN_LIST FEATURES`) to build switches that are forced ON, with the dependency looked up REQUIRED, when selected and explicitly OFF otherwise. Adding a dependency to a feature without portfile logic, `if(TARGET ...)` guards, forced options contradicting a feature, or an empty selection that builds everything detectable is wrong. Otherwise a requested feature can silently vanish or appear unrequested.
- **Check:** For each feature, find its portfile mapping and the upstream option it drives, and build `port[core]` with the feature's dependency preinstalled; options needing several features must check all of them. Prefer upstream options where `CMAKE_DISABLE_FIND_PACKAGE_<Pkg>` would also block transitive lookups (e.g., WrapOpenSSL for Qt6Network).
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Explicitly control dependencies](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#when-defining-features-explicitly-control-dependencies); PRs: [#47547](https://github.com/microsoft/vcpkg/pull/47547#discussion_r2388573979), [#46253](https://github.com/microsoft/vcpkg/pull/46253#discussion_r2181038311)

### DEP-006: Declare every dependency the build and installed files need

- **Rule:** vcpkg.json must list every port the build uses directly (libraries and tools, even if currently satisfied transitively or newly required by an update) and every port that installed headers, CMake configs, or pkg-config files need; unconditional public includes require a core dependency, while optional APIs can use an opt-in feature. Verify with a clean install: undeclared dependencies only work when something else installed them.
- **Check:** Compare REQUIRED `find_package`, pkg-config, and `#include` usage in sources, installed headers, and configs (`find_dependency`) with vcpkg.json; look for "Could not find a package configuration file provided by X" in clean CI and patches that force lookups of unlisted packages.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: dependencies](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#dependencies); PRs: [#54209](https://github.com/microsoft/vcpkg/pull/54209#pullrequestreview-5387554687), [#52971](https://github.com/microsoft/vcpkg/pull/52971#pullrequestreview-4767248862)

### DEP-007: Never let features switch published APIs or ABI

- **Rule:** A feature must not change the API or ABI that core-only consumers see: no char/wchar_t switches, namespaces, type redefinitions, or C++-standard modes (cxx17/cxx20), and an upstream minimum C++ standard is not a feature. The only exception is a polyfill-to-alias switch baked into installed headers (INT-011). Otherwise consumers break as soon as any dependent enables the feature.
- **Check:** Look for features named `cxx17`/`cxx20`/`std-*`/`wchar` or adding compile definitions that alter public types, namespaces, or macros, and public headers selecting APIs via `__cplusplus` that can differ between build and consumption.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Alternatives in published interfaces](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-use-features-to-control-alternatives-in-published-interfaces); PRs: [#44236](https://github.com/microsoft/vcpkg/pull/44236#discussion_r1996016270), [#24355](https://github.com/microsoft/vcpkg/pull/24355#issuecomment-1107683517)

### DEP-008: Never decide build behavior by probing the installed tree

- **Rule:** Ports must not be path dependent: nothing may be decided by probing what is installed (`__has_include`, `check_include_file`, `if(EXISTS "${CURRENT_INSTALLED_DIR}/...")`, presence checks on other ports to enforce mutual exclusion) or by runtime plugin/dlopen fallbacks; use portfile-controlled options and link-time dependencies. When adding a port, check that existing ports won't start auto-detecting it. Installing a then b must equal installing b then a.
- **Check:** Grep portfiles, patches, and upstream code for `__has_include`, `check_include_file`, `if(EXISTS` on `CURRENT_INSTALLED_DIR`, and hard-coded DLL names for plugin loading. For new ports, grep likely consumers for optional lookups of the library and compare their builds with it preinstalled.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must not be path dependent](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-not-be-path-dependent); PRs: [#53259](https://github.com/microsoft/vcpkg/pull/53259#discussion_r3731915033), [#23725](https://github.com/microsoft/vcpkg/pull/23725#issuecomment-1079296155)

### DEP-009: Pin Meson auto features and autotools detection explicitly

- **Rule:** Meson feature options defaulting to `auto`, `dependency(..., required: false)`, and autotools checks that auto-detect libraries must be pinned explicitly (`-D<opt>=enabled|disabled`, `--with/--without-<x>`, `--enable/--disable-<x>`) unless the dependency is declared and required; meson projects lacking an option need a patch. Opportunistically found host tools must be forced off or declared as host dependencies. Building before versus after installing zstd must not change the binaries.
- **Check:** Compare meson_options.txt/meson.options and configure.ac defaults (`auto`, `check`) with OPTIONS passed to `vcpkg_configure_meson`/`vcpkg_make_configure`. Flag `=auto` in the portfile and log lines such as "Run-time dependency X found: YES", "Program X found", or "checking for X... yes" for undeclared packages.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must not be path dependent](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-not-be-path-dependent); PRs: [#54238](https://github.com/microsoft/vcpkg/pull/54238#pullrequestreview-5399448023), [#52466](https://github.com/microsoft/vcpkg/pull/52466#pullrequestreview-4520492548)

### DEP-010: Re-audit dependency control on every version update

- **Rule:** When updating, diff upstream build scripts and bundled-source directories between the old and new release: new auto-detected or default-ON dependencies, changed option defaults, and newly vendored libraries must be controlled, declared, or devendored in the same PR. Dropping patches or options that controlled dependencies or devendored code is a regression, as is keeping a declared dependency whose option is now off. Updates must not make a deterministic package environment-dependent.
- **Check:** Run `git diff <old-tag> <new-tag> -- CMakeLists.txt cmake/ meson* configure.ac third_party/`; look for new `find_package` calls, `AUTO` options, renamed or removed options still mapped by features, new bundled copies, and deleted dependency-control patches in the PR diff.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [Maintainer guide: Explicitly control dependencies](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#when-defining-features-explicitly-control-dependencies); PRs: [#52762](https://github.com/microsoft/vcpkg/pull/52762#issuecomment-4900061907), [#52491](https://github.com/microsoft/vcpkg/pull/52491#pullrequestreview-4535447370)

### DEP-011: Ensure devendoring actually replaces the bundled copy

- **Rule:** A declared dependency meant to replace bundled code must really be consumed: delete or disable the bundled sources before building, make the lookup REQUIRED so the build cannot fall back to the copy, and wire new devendoring ports into their consumer in the same PR. Consume the port through its official package and imported targets, never hard-coded installed-tree paths. Otherwise the dependency costs build time while the vendoring persists.
- **Check:** Read build logs and CMakeCache for bundled sources still compiled or `third_party` include paths, confirm the dependency appears on the link line or in exported configs, and flag patches adding `${VCPKG_INSTALLED_DIR}/...` or `CURRENT_INSTALLED_DIR` include paths.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not use vendored dependencies](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-use-vendored-dependencies); PRs: [#54052](https://github.com/microsoft/vcpkg/pull/54052#pullrequestreview-5297935553), [#53840](https://github.com/microsoft/vcpkg/pull/53840#pullrequestreview-5203184610)

### DEP-012: Use vcpkg ports instead of system library copies

- **Rule:** Declare and use the vcpkg port for anything the build consumes that vcpkg provides or can reasonably add, instead of system or SDK copies; don't turn ports into empty stubs deferring to the system, drop dependencies, or disable functionality just to pass CI (add missing ports first). Users wanting system libraries use empty overlay ports. Build time is no excuse (binary caching mitigates it); exceptions are in DEP-019.
- **Check:** Look for configure logs resolving packages from /usr, system lib dirs, or the macOS SDK for things vcpkg ships, wrappers pointing at `CMAKE_OSX_SYSROOT`, `VCPKG_POLICY_EMPTY_PACKAGE` or early `return()` under platform conditions, and PRs removing dependencies or adding `-DWITH_X=OFF` only to fix builds.
- **Severity:** blocking · **Scope:** all
- **Sources:** [CMake integration: VCPKG_PREFER_SYSTEM_LIBS](https://learn.microsoft.com/vcpkg/users/buildsystems/cmake-integration#vcpkg_prefer_system_libs); PRs: [#51896](https://github.com/microsoft/vcpkg/pull/51896#pullrequestreview-4339559202), [#36585](https://github.com/microsoft/vcpkg/pull/36585#issuecomment-2022665474)

### DEP-013: Never add features that remove or restrict functionality

- **Rule:** Features may only add functionality: no `disable-<x>`, `no-<x>`, `<x>-only`, debug-level-0, or similar off-switches, and no feature whose enabling would remove a dependency or existing API. Define the positive feature instead (mapped with `INVERTED_FEATURES`; default only per DEP-004) or hardcode one choice. Given that `port[core]` works, `port[a]` must work for every consumer, since no dependent can require a feature to be off.
- **Check:** Flag feature names or descriptions containing disable, no-, only, or restrict, mappings where enabling a feature turns an upstream capability OFF, and features that must drop a dependency; verify code written against `port[core]` still compiles with the feature on.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Features concept](https://learn.microsoft.com/vcpkg/concepts/features#features); [Maintainer guide: Do not use features to implement alternatives](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-use-features-to-implement-alternatives); PRs: [#28730](https://github.com/microsoft/vcpkg/pull/28730#discussion_r1080600927), [#25551](https://github.com/microsoft/vcpkg/pull/25551#pullrequestreview-1028240811)

### DEP-014: Leave niche variants to overlay ports or triplet settings

- **Rule:** Niche or project-specific configurations (CUDA-version builds, alternative backends, experimental functionality) don't become features, ports, or triplets; the registry picks one configuration and may document overlay instructions, since every variant costs CI and maintenance. Codegen or environment choices consumers may need off (fast-math, SIMD, OpenMP, target OS version) get a portfile default overridable from a custom triplet. Preview features are allowed only when unlikely to disrupt non-preview functionality.
- **Check:** Flag PRs adding features, ports, or options for one user's configuration, features that only change codegen or performance, and `experimental-*` features; overridable settings should use `if(NOT DEFINED <VAR>)` with an explanatory comment.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Recommended solutions](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#recommended-solutions); [Maintainer guide: Preview or beta features](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#a-feature-may-engage-preview-or-beta-functionality); PRs: [#38275](https://github.com/microsoft/vcpkg/pull/38275#issuecomment-2159396710), [#54379](https://github.com/microsoft/vcpkg/pull/54379#issuecomment-6087236244)

### DEP-015: Make each feature deliver what it advertises

- **Rule:** Each feature must actually build and install the functionality its description claims, declaring every dependency it needs (including features of dependencies or of the same port) and runtime prerequisites; a feature that only adds a dependency, or whose option affects nothing built, must be fixed or removed. `port[core]` and each `port[core,<feature>]` must yield consumable packages, so configs must not reference disabled features' targets. Misleading features confuse users and dependents.
- **Check:** Install `port[core]` and `port[core,<feature>]`, diff installed files, and consume each config; read configure output for "disabled because X not found", built-but-uninstalled executables, and features overridden by hard-coded options (e.g., a tests feature passing `BUILD_TESTS=OFF`).
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#54225](https://github.com/microsoft/vcpkg/pull/54225#pullrequestreview-5397363147), [#25578](https://github.com/microsoft/vcpkg/pull/25578#issuecomment-1222091998)

### DEP-016: Make the core configuration functional out of the box

- **Rule:** `vcpkg install <port>` must give typical users a working library: use the platform's de facto backend (Schannel on Windows, Secure Transport on macOS, OpenSSL elsewhere) rather than a dummy or empty configuration, and unconditionally enable anything without which the package is broken instead of hiding it behind a feature. Users with other needs use overlays; default features still must not add APIs.
- **Check:** Inspect core and per-platform backend selection (`VCPKG_TARGET_IS_*`), confirm `port[core]` performs its basic task (e.g., TLS using system root certificates), and check that essential link libraries aren't feature-gated.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#46459](https://github.com/microsoft/vcpkg/pull/46459#discussion_r2258499975), [#52862](https://github.com/microsoft/vcpkg/pull/52862#discussion_r3625773224)

### DEP-017: Use implementations selected by blas, lapack, and mpi meta-ports

- **Rule:** Ports needing BLAS, LAPACK, or MPI depend on the `blas`, `lapack`, or `mpi` meta-ports and use what they select (`find_package(BLAS)`), never hard-coding a vendor such as OpenBLAS, Accelerate, or reference LAPACK per port; failing with a clear error on an unusable selection is acceptable. Implementation ports must not install into a meta-port's share directory, and per-triplet selection changes are registry-wide decisions. Mixed implementations cause ODR conflicts.
- **Check:** Flag vcpkg.json dependencies on openblas or lapack-reference, options like `--with-blas=openblas` or `-DBLAS=<vendor>`, implementation ports writing `share/<meta-port>/` files, and PRs changing the per-triplet backend in ports/blas or ports/lapack.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Unique port attribution](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#unique-port-attribution-rule); PRs: [#46696](https://github.com/microsoft/vcpkg/pull/46696#discussion_r2248705220), [#50520](https://github.com/microsoft/vcpkg/pull/50520#issuecomment-4079893744)

### DEP-018: Update dependencies together when versions must match

- **Rule:** If a new upstream version needs APIs a dependency's registry version lacks, or a companion port must match (volk and vulkan-headers, Qt or Boost module sets), update that port in the same PR or wait for it, rather than vendoring a newer copy; claims that a bundled newer version is required need concrete evidence. vcpkg builds the baseline graph, so incompatible pairs fail everywhere.
- **Check:** Look for CI compile errors on all triplets about missing dependency functions or types, upstream minimum dependency versions newer than versions/baseline.json, and SDK components updated while paired headers or core ports stay older.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** PRs: [#54708](https://github.com/microsoft/vcpkg/pull/54708#pullrequestreview-5705597191), [#54183](https://github.com/microsoft/vcpkg/pull/54183#pullrequestreview-5375314206)

### DEP-019: Make unavoidable system dependencies explicit and fail loudly

- **Rule:** A system-provided dependency must fail the build when missing, or be an explicit opt-in, off and not auto-detected by default, with an early portfile message naming the system packages. Only polyfills and system-matched components may defer to the system as empty packages: X11 libraries on non-Windows follow the x-port pattern (unless the triplet sets `X_VCPKG_FORCE_VCPKG_X_LIBRARIES`); Linux windowing stacks come from the system. Uncontrolled dependencies make builds flaky.
- **Check:** Look for portfile notes like "must be installed on the host system" while the build still succeeds without it, system-library auto-detection (speech-dispatcher, acl, ibus) left enabled, and new X11 ports restricted to `"supports": "windows"` instead of following the x-port pattern.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist: c000012](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000012); [Maintainer guide: Explicitly control dependencies](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#when-defining-features-explicitly-control-dependencies); PRs: [#49486](https://github.com/microsoft/vcpkg/pull/49486#discussion_r2709766981), [#22642](https://github.com/microsoft/vcpkg/pull/22642#discussion_r788258433)

### DEP-020: Depend on python3 only when building against Python

- **Rule:** Use `vcpkg_find_acquire_program(PYTHON3)` (or a system interpreter) only to run build scripts that need no extra modules and whose results don't depend on the target. Anything that builds Python extension modules or bindings, links or embeds libpython, or loads vcpkg-built binaries into Python must depend on the `python3` port. Binaries loaded into Python only work reliably with vcpkg's python, while building Python just to run a script is wasteful.
- **Check:** Flag ports building bindings or linking libpython while only calling `vcpkg_find_acquire_program(PYTHON3)`, and vcpkg.json depending on python3 solely to run .py generators; ask why Python is needed.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#37931](https://github.com/microsoft/vcpkg/pull/37931#discussion_r1579627776), [#36585](https://github.com/microsoft/vcpkg/pull/36585#issuecomment-2010321478)

### DEP-021: Platform-qualify dependencies and features needed only on some platforms

- **Rule:** Dependencies needed only on some platforms, or whose "supports" is narrower than the port's and its dependents', need a "platform" qualifier (or fix the blocking port). Enforce a feature mandatory on some platforms with a platform-qualified self-dependency (`"default-features": false`) instead of `message(FATAL_ERROR)` or duplicate per-platform features, so the resolver selects it. Platform- or linkage-limited functionality can be a feature with its own "supports" rather than silently patched out.
- **Check:** Run `vcpkg install --dry-run` of the port and its dependents (including scripts/test_ports CI ports) per triplet, compare each dependency's "supports" with the port's, and flag portfile `FATAL_ERROR`s demanding a feature on some platform.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg.json reference: dependency platform](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#dependency-platform); [vcpkg.json reference: dependency features](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#dependency-features); PRs: [#54636](https://github.com/microsoft/vcpkg/pull/54636#discussion_r4370177413), [#46863](https://github.com/microsoft/vcpkg/pull/46863#discussion_r2266228011)

### DEP-022: Keep dependents working when removing or splitting features

- **Rule:** Before removing or renaming a feature, update `<port>[<feature>]` users in ports/ in the same PR and keep an empty no-op or alias feature ("kept for compatibility") if users may still request it; never-working features can simply go. When moving existing functionality into a new feature, first run CI with it non-default to find dependents needing an explicit feature dependency. Otherwise manifests and upgrades break.
- **Check:** For vcpkg.json diffs deleting or renaming features, grep `ports/*/vcpkg.json` for dependencies on that feature; for new features carving out existing APIs (turbojpeg, `gtk3[wayland]`), check reverse dependencies' use of the moved API.
- **Severity:** non-blocking · **Scope:** port-update
- **Sources:** PRs: [#28492](https://github.com/microsoft/vcpkg/pull/28492#issuecomment-1367266199), [#54986](https://github.com/microsoft/vcpkg/pull/54986#discussion_r4540857608)

### DEP-023: Remove broken, meaningless, or upstream-unsupported features

- **Rule:** Don't add or keep features that don't build, no longer have any effect, lack vcpkg ports for their dependencies, map to options upstream dropped or deems unsupported ("not recommended"), or have a broken off state; remove them (opening an issue to re-add later) and hardcode the working setting, preserving compatibility per DEP-022. Before dropping one as upstream "builtin", verify it isn't still optional. Broken features become back-compat obligations.
- **Check:** Look for features failing in feature tests or added to ci.feature.baseline.txt as failing, features mapped to options absent from or deprecated upstream, core builds failing because public headers need a feature, and feature sources pinned to stale branches.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#53590](https://github.com/microsoft/vcpkg/pull/53590#pullrequestreview-5061808363), [#45011](https://github.com/microsoft/vcpkg/pull/45011#issuecomment-2807316535)

### DEP-024: Curate features as capabilities users meaningfully choose

- **Rule:** Add a feature only when users have a compelling reason to choose it (heavy optional dependency, platform limits, real demand); name it after the capability (mp3, ldap, gui), describe the components it pulls in, and group per-platform implementations via platform-qualified dependencies. Don't mirror every upstream option, re-expose dependencies' features except durable capabilities (e.g., ssl), or split off dependency-free components; build those unconditionally. Every feature multiplies untested configurations.
- **Check:** Compare features with upstream options; flag features for tests, docs, coverage, ccache, or install toggles, features mass-generated from option lists, features named after one library or platform variant (winldap vs openldap), and passthrough features that only forward a dependency's features.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [PR review checklist: c000009](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000009); PRs: [#47321](https://github.com/microsoft/vcpkg/pull/47321#discussion_r2350968602), [#43540](https://github.com/microsoft/vcpkg/pull/43540#issuecomment-2624829657)

### DEP-025: Declare only used dependencies; fix problems in owning ports

- **Rule:** Don't list dependencies the build never consumes, and don't add spurious dependencies, consumer patches, or feature splits to work around another port's defects (missing exported link requirements, unexpected library names, host failures); fix or report the owning port, adding (unofficial) CMake integration there if needed. Avoid features or patches creating circular or upstream-unsupported coupling between ports. Workarounds hide the bug and leave other consumers broken.
- **Check:** Flag new vcpkg.json dependencies never referenced by upstream sources or configure output (e.g., lz4 for dbus), consumer patches compensating for a dependency's link info, and feature graphs where `A[x]` depends on B which depends on A.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#35129](https://github.com/microsoft/vcpkg/pull/35129#issuecomment-1812932785), [#38712](https://github.com/microsoft/vcpkg/pull/38712#issuecomment-2112180645)

### DEP-026: Put optional executables behind a non-default tools feature

- **Rule:** Don't build or install executables the library doesn't need; if useful, put them behind a non-default `tools` feature, and disable unused tool targets, especially ones probing undeclared dependencies. A `port[tool]` feature is only for tools produced by the same build as the library; separately built or prebuilt tools belong in their own port. Tools add build time, dependencies, and interfaces to every install.
- **Check:** Look for many executables in `bin/` or `tools/<port>/` without a tools feature, `BUILD_TOOLS`/`BUILD_UTILS`-style options left ON, tools features listed in `default-features`, and tool features that trigger a separate build or binary download.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Default features enable behaviors, not APIs](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#default-features-should-enable-behaviors-not-apis); PRs: [#49474](https://github.com/microsoft/vcpkg/pull/49474#pullrequestreview-3676768126), [#44761](https://github.com/microsoft/vcpkg/pull/44761#issuecomment-2779438350)

### DEP-027: Don't hardcode other ports' versions in portfiles or patches

- **Rule:** Avoid hardcoding values that must track another port's version (`-D<dep>_VERSION_*` macros, toolchain or assembler versions, `find_package(<dep> <major> REQUIRED)`); derive them at build time or drop the version argument. If a fixed value is really safe, add a portfile comment explaining why so the next updater can re-check it. Overrides let users combine different port versions.
- **Check:** Flag portfile options or patch hunks containing literal versions of other packages, and patches that bump `find_package(<dep> 13)` to 14 instead of removing the version.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#25591](https://github.com/microsoft/vcpkg/pull/25591#discussion_r936125702), [#42437](https://github.com/microsoft/vcpkg/pull/42437#discussion_r1866779532)

### DEP-028: Target the canonical current variant of multi-version libraries

- **Rule:** When a library has co-existing major variants (qt5/Qt 6, opencv3/opencv4), depend on and test with the current canonical one (Qt 6, opencv4); patches kept only for older variants may be dropped. Don't split ports or add features that choose a dependency's major version, since that is an alternative. vcpkg tests one canonical configuration.
- **Check:** Flag new or updated ports depending on `qt5-*` or opencv3 when upstream supports the current variant, features named after dependency majors (qt5/qt6), and patches or `#if` blocks existing only for an older variant.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not use features to implement alternatives](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-use-features-to-implement-alternatives); PRs: [#46422](https://github.com/microsoft/vcpkg/pull/46422#discussion_r2505938183), [#46399](https://github.com/microsoft/vcpkg/pull/46399#discussion_r2229558228)

### DEP-029: Prefer VCPKG_LOCK_FIND_PACKAGE for optional find_package control

- **Rule:** Control optional CMake `find_package` calls with `VCPKG_LOCK_FIND_PACKAGE_<Pkg>` (mapped through `vcpkg_check_features`), which affects only the port's own non-nested lookups. `CMAKE_DISABLE_FIND_PACKAGE_<Pkg>` for widely used packages such as ZLIB can also block `find_dependency` calls inside other dependencies' configs and break the build.
- **Check:** `INVERTED_FEATURES` entries or options setting `CMAKE_DISABLE_FIND_PACKAGE_<common package>` in ports with many dependencies; enabled features that neither require nor lock the package, so a missing package doesn't fail loudly.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [CMake integration: VCPKG_LOCK_FIND_PACKAGE_<Pkg>](https://learn.microsoft.com/vcpkg/users/buildsystems/cmake-integration#vcpkg_lock_find_package_pkg); PRs: [#49252](https://github.com/microsoft/vcpkg/pull/49252#discussion_r2674174771), [#27728](https://github.com/microsoft/vcpkg/pull/27728#discussion_r1019916515)

### DEP-030: Name features after capabilities using upstream terminology

- **Rule:** Name new features after the capability users get, in the terms upstream's options and documentation use (for example `dbpage-vtab` for `SQLITE_ENABLE_DBPAGE_VTAB`, `ssl` rather than `openssl`), so users can find them. Many existing ports name features after dependencies; don't rename established features just for this.
- **Check:** Compare each new feature name with the upstream option and documentation wording it toggles; flag names that only repeat a dependency's port name or invent unrelated terms.
- **Severity:** advisory · **Scope:** all
- **Sources:** [PR review checklist: c000009](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000009); PRs: [#39424](https://github.com/microsoft/vcpkg/pull/39424#discussion_r1659607819), [#50136](https://github.com/microsoft/vcpkg/pull/50136#issuecomment-3949573174)

## BLD: Build configuration and build systems

### BLD-001: Do not build tests, examples, benchmarks or docs

- **Rule:** Turn off upstream tests, examples, samples, benchmarks, demos, docs and developer-only checks via options (`BUILD_TESTING=OFF`, `*_BUILD_TESTS`/`*_EXAMPLES=OFF`, meson `-Dtests=disabled`), patching the build when no switch exists, including targets built but not installed. An optional `test` feature is fine but never default; when a failure occurs only in test or example code, disabling them is the fix. This saves build time and dependencies for every user.
- **Check:** OPTIONS lacking test/example/doc switches or relying on `PROJECT_IS_TOP_LEVEL` defaults; logs compiling tests or examples, running doxygen or `gtest_discover_tests`; installed `*_test` executables; patches fixing test-only code; `file(REMOVE)` of built binaries instead of not building them.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not build tests/docs/examples by default](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-build-testsdocsexamples-by-default); PRs: [#52723](https://github.com/microsoft/vcpkg/pull/52723#pullrequestreview-4642006552), [#54581](https://github.com/microsoft/vcpkg/pull/54581#pullrequestreview-5620277460)

### BLD-002: Build and install only the linkage the triplet requests

- **Rule:** Build and install exactly one variant, selected by `VCPKG_LIBRARY_LINKAGE` (`BUILD_SHARED_LIBS` or options computed from it); when upstream builds both, patch minimally (`EXCLUDE_FROM_ALL` plus a conditional install) and unify names that differ only by variant. DLLs in static triplets usually mean insufficient linkage control: stop building them rather than deleting them or setting `VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY`, and never make a dependency install both kinds for another port. vcpkg makes one linkage available at a time.
- **Check:** Both static and shared artifacts of one library (`foo.lib` plus `foo_static.lib`, `.a` plus `.so`); hard-coded `*_BUILD_SHARED`/`*_BUILD_STATIC` options; post-build "DLLs should not be present in a static build"; portfiles deleting `bin/` or `*.dll` only for static linkage.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Choose either static or shared binaries](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#only-static-or-shared); [Policies: VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_dlls_in_static_library); PRs: [#48327](https://github.com/microsoft/vcpkg/pull/48327#pullrequestreview-3879541572), [#36836](https://github.com/microsoft/vcpkg/pull/36836#issuecomment-1987686208)

### BLD-003: Never add CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS; keep export-less libraries static on Windows

- **Rule:** Don't add `CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS` or `WINDOWS_EXPORT_ALL_SYMBOLS` (options, patches, port CMakeLists) unless upstream already uses it; it interacts poorly with templates and compiler features. Libraries without `__declspec` or `.def` exports don't support Windows DLLs: use `if(VCPKG_TARGET_IS_WINDOWS) vcpkg_check_linkage(ONLY_STATIC_LIBRARY) endif()` so other platforms keep shared builds, and report missing exports upstream rather than carrying huge annotation patches or setting `VCPKG_POLICY_DLLS_WITHOUT_LIBS`/`VCPKG_POLICY_DLLS_WITHOUT_EXPORTS`.
- **Check:** grep portfile, patches and port CMakeLists for `WINDOWS_EXPORT_ALL_SYMBOLS`; post-build "DLLs were built without any exports" or missing import libraries; unconditional `ONLY_STATIC_LIBRARY` or an extra `-DBUILD_SHARED_LIBS=OFF` justified by dllexport problems.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not add CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-add-cmake_windows_export_all_symbols); [Policies: VCPKG_POLICY_DLLS_WITHOUT_EXPORTS](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_dlls_without_exports); PRs: [#50047](https://github.com/microsoft/vcpkg/pull/50047#discussion_r2819236483), [#43073](https://github.com/microsoft/vcpkg/pull/43073#issuecomment-2569566042)

### BLD-004: Take build-time tools from the host triplet when cross-compiling

- **Rule:** Tools executed during the build (code generators, protoc-like compilers) must run on the host: native builds may build and run them in-tree, but when `VCPKG_CROSSCOMPILING` they must come from a `"host": true` dependency (often the port itself) under `${CURRENT_HOST_INSTALLED_DIR}/tools`, passed explicitly (`-D<TOOL>_EXECUTABLE`, meson `ADDITIONAL_BINARIES`). Never run target binaries in cross builds or build host tools via ExternalProject, an assumed `CC=gcc` or `uname` detection; arm64-android binaries can't run on the build machine.
- **Check:** Cross-build (arm64-android, arm64-windows, x86-windows on x64) and look for missing `VCPKG_CROSSCOMPILING` branches or self host dependency, `add_custom_command` running build-tree tools, and `CURRENT_HOST_INSTALLED_DIR` paths without a matching host dependency; native DLL load failures (0xc0000135) need dependency `bin` dirs on PATH.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Host dependencies: Producing](https://learn.microsoft.com/vcpkg/users/host-dependencies#producing); [vcpkg.json: dependency host](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#dependency-host); [Variables: VCPKG_CROSSCOMPILING](https://learn.microsoft.com/vcpkg/maintainers/variables#vcpkg_crosscompiling); PRs: [#37950](https://github.com/microsoft/vcpkg/pull/37950#discussion_r1553783094), [#29003](https://github.com/microsoft/vcpkg/pull/29003#discussion_r1081764643)

### BLD-005: Build with the compilers the triplet and toolchain select

- **Rule:** Compile with the C/C++ compilers and toolchain vcpkg derives from the triplet or chainloaded toolchain, because the compiler is the user's choice. Don't set `CC`/`CXX` or `CMAKE_<LANG>_COMPILER`, include toolchain files, set `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` or `CMAKE_CROSSCOMPILING`, or force clang, clang-cl or MinGW. A downloaded compiler is acceptable only as an assembler or when it produces no installed binaries; clang-only libraries should fail with a clear diagnostic plus CI baseline entries.
- **Check:** Portfiles, patches or upstream CMake setting compilers (`CC=gcc`, clang paths), downloading LLVM/GCC, `include()`-ing toolchain files, passing `-DCMAKE_CROSSCOMPILING` or using `vcpkg_find_acquire_program(CLANG)` beyond ASM; `vcpkg_find_fortran` silently switching a Windows build's C/C++ to MinGW.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_find_fortran](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_find_fortran); PRs: [#29032](https://github.com/microsoft/vcpkg/pull/29032#discussion_r1081872010), [#43858](https://github.com/microsoft/vcpkg/pull/43858#issuecomment-2670740031)

### BLD-006: Link the C runtime selected by VCPKG_CRT_LINKAGE

- **Rule:** Binaries must use the CRT the triplet requests (`/MD` vs `/MT`, debug CRT for debug builds) and its architecture: patch upstream code hard-coding `/MT` or `/MD`, forcing `CMAKE_MSVC_RUNTIME_LIBRARY` or overwriting `CMAKE_<LANG>_FLAGS`, and never copy release binaries into `debug/`. Don't pass `VCPKG_CRT_LINKAGE` values as `CMAKE_MSVC_RUNTIME_LIBRARY`, pick a static standard library (`-static-libstdc++`) per port, or silence CRT/architecture post-build checks with policies. Runtime linkage is a triplet setting.
- **Check:** Post-build errors about inconsistent or invalid CRT linkage, outdated dynamic CRT or incorrect architecture; `dumpbin /directives`; upstream `string(REPLACE "/MD" "/MT" ...)`; new `VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT`/`VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK`; exported `-static-libgcc`/`-static-libstdc++`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Triplets: VCPKG_CRT_LINKAGE](https://learn.microsoft.com/vcpkg/users/triplets#vcpkg_crt_linkage); [Policies: VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_allow_obsolete_msvcrt); [Policies: VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_skip_architecture_check); PRs: [#34123](https://github.com/microsoft/vcpkg/pull/34123#issuecomment-1760348845), [#50058](https://github.com/microsoft/vcpkg/pull/50058#discussion_r2830735078)

### BLD-007: Never build DLLs against a static CRT

- **Rule:** Ports must never produce DLLs against a static CRT or switch `VCPKG_LIBRARY_LINKAGE` to dynamic themselves; only a user's custom triplet may request that combination. Ports needing `ONLY_DYNAMIC_LIBRARY` declare `!(static & staticcrt)` in `supports` because `vcpkg_check_linkage` refuses it, and a component that can only be a DLL (e.g., a plugin) is acceptable in static triplets only with dynamic CRT. Each DLL would otherwise carry its own CRT state.
- **Check:** CI error "Refusing to build unexpected dynamic library against the static CRT"; `ONLY_DYNAMIC_LIBRARY` without the supports clause; portfiles or triplets combining dynamic `VCPKG_LIBRARY_LINKAGE` with static `VCPKG_CRT_LINKAGE`; plugin DLLs in x64-windows-static.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_check_linkage: Notes](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_check_linkage#notes); PRs: [#52127](https://github.com/microsoft/vcpkg/pull/52127#pullrequestreview-4432054160), [#32603](https://github.com/microsoft/vcpkg/pull/32603#issuecomment-1646223076)

### BLD-008: Restrict linkage only through justified vcpkg_check_linkage calls

- **Rule:** Never set `VCPKG_LIBRARY_LINKAGE` in a portfile; restrict linkage with `vcpkg_check_linkage(ONLY_STATIC_LIBRARY|ONLY_DYNAMIC_LIBRARY)` near the top, and only for a concrete technical reason such as upstream always building one kind or a DLL-only redistributable—not ABI or SDK preferences, CRT-based heuristics or speculative licensing. Make upstream-forced linkage explicit instead of silently delivering the other kind; the triplet, not the port, chooses linkage, and users needing other combinations use per-port triplet customization.
- **Check:** `set(VCPKG_LIBRARY_LINKAGE ...)` in portfiles; `vcpkg_check_linkage` without a stated reason or although upstream has shared-library rules; upstream hard-coding `add_library(... STATIC|SHARED)` with no matching `vcpkg_check_linkage`; dynamic-triplet packages containing only static libraries.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_check_linkage](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_check_linkage); [PR review guide: criterion 17](https://github.com/microsoft/vcpkg/blob/master/.github/skills/shared/review-vcpkg-pr-guide.md); [Triplets: Per-port customization](https://learn.microsoft.com/vcpkg/users/triplets#per-port-customization); PRs: [#53275](https://github.com/microsoft/vcpkg/pull/53275#pullrequestreview-4887492417), [#47673](https://github.com/microsoft/vcpkg/pull/47673#issuecomment-3373411074)

### BLD-009: Leave toolchain-wide and target-platform settings to the triplet

- **Rule:** Settings the triplet or toolchain owns, or that must match across the dependency graph—CPU ISA, optimization/fast-math, CUDA architectures, emscripten threading, `/clr`, ABI-wide switches such as a Qt namespace, `MACOSX_DEPLOYMENT_TARGET`, `CMAKE_SYSTEM_PROCESSOR`, the Visual Studio instance—must not be hard-coded, re-derived (vswhere, `VCPKG_PLATFORM_TOOLSET`) or exposed as features by a port. Honor triplet values; users customize them via custom triplets, `VCPKG_CMAKE_CONFIGURE_OPTIONS` or per-port triplet logic.
- **Check:** Features or options mapping to compiler flags (avx2, fast-math, CUDA architectures; fftw3-style CPU features are tolerated precedent); CPU extensions on by default rather than via documented `<PORT>_<CPUTHING>` triplet variables; `-DCMAKE_SYSTEM_PROCESSOR`, `MACOSX_DEPLOYMENT_TARGET` or vswhere logic in portfiles or patches.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Triplets: Per-port customization](https://learn.microsoft.com/vcpkg/users/triplets#per-port-customization); [Triplets: VCPKG_CMAKE_CONFIGURE_OPTIONS](https://learn.microsoft.com/vcpkg/users/triplets#vcpkg_cmake_configure_options); [Maintainer guide: Portfiles are run in Script Mode](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#portfiles-are-run-in-script-mode); PRs: [#46540](https://github.com/microsoft/vcpkg/pull/46540#issuecomment-3225621271), [#48132](https://github.com/microsoft/vcpkg/pull/48132#discussion_r2492263405)

### BLD-010: Acquire every build tool explicitly and pass its path

- **Rule:** Default builds must work with what vcpkg provides: obtain tools and interpreters (pkg-config, SWIG, python3, perl, bison) via `vcpkg_find_acquire_program`, host tool ports, or hash-pinned per-host downloads, pass their paths explicitly (e.g., `-DPKG_CONFIG_EXECUTABLE`), and prepend vcpkg copies to PATH so system copies can't win. Don't hand-set `PKG_CONFIG_PATH` or `--prefix`, which the make and meson helpers manage per configuration, and don't rely on tools present on CI images or helper-port side effects.
- **Check:** `find_program` for tools without acquisition; "Could NOT find PkgConfig/SWIG" on clean machines; `set(ENV{PKG_CONFIG_PATH} ...)` in portfiles; logs using `/usr/bin` tools; ports expecting a specific Python from `vcpkg_find_acquire_program(PYTHON3)` instead of the python3 port.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist: c000012](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000012); [Host dependencies: Consuming](https://learn.microsoft.com/vcpkg/users/host-dependencies#consuming); PRs: [#28693](https://github.com/microsoft/vcpkg/pull/28693#issuecomment-1377998275), [#41871](https://github.com/microsoft/vcpkg/pull/41871#discussion_r1824298851)

### BLD-011: Keep build results independent of the build machine

- **Rule:** Package contents must depend only on the triplet and declared inputs: no `-march=native` or CPU autodetection (pin such options deterministically), no environment variables or probing the machine for optional SDKs, and no network downloads during configure or build. Builds must also run unattended, never waiting for input. Binary caches share results across machines, and untracked inputs aren't part of the ABI hash.
- **Check:** `$ENV{...}` selecting options; `-march=native`/`-mtune=native` or host-CPU detection in upstream CMake or patches; ISA-autodetecting options (e.g., `AVX_TYPE`) left unset; FetchContent, `file(DOWNLOAD)` or git calls at configure time; configure scripts that prompt.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Binary caching: ABI hash](https://learn.microsoft.com/vcpkg/reference/binarycaching#abi-hash); PRs: [#40868](https://github.com/microsoft/vcpkg/pull/40868#issuecomment-2348306503), [#54636](https://github.com/microsoft/vcpkg/pull/54636#discussion_r4488536756)

### BLD-012: Do not force a C++ standard on consumers

- **Rule:** The C++ standard is the user's toolchain or triplet choice: ports must tolerate mixed standards in one link, must not set `CMAKE_CXX_STANDARD` in the portfile without a demonstrated need, and must not push a standard onto consumers beyond what the API requires. If the ABI depends on the standard used, record that in the installed files; adding a dependency shouldn't silently change the consumer's standard.
- **Check:** `-DCMAKE_CXX_STANDARD=` in portfile options; patches adding `cxx_std_XX` usage requirements or standard detection; PRs "enabling C++20" to fix one user's link error; `-std` flags in exported targets.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#21942](https://github.com/microsoft/vcpkg/pull/21942#discussion_r785233302), [#25855](https://github.com/microsoft/vcpkg/pull/25855#issuecomment-1212433461)

### BLD-013: Scope workarounds narrowly; don't patch around broken toolchains

- **Rule:** Condition workarounds on the platform or toolchain that needs them (e.g., MinGW-only link fixes) instead of pessimizing mainstream targets, such as by disabling SIMD globally or catering to Windows XP. Don't patch ports for incorrect custom toolchains, broken platform linkers or bugs in user-installed tools (e.g., Homebrew CMake) unless the problem reproduces with a correct toolchain; users should fix their toolchain, which has hooks for such settings.
- **Check:** Unconditional `-D<X>=OFF` or disabled assembly added for one triplet's failure; options chosen for legacy OS support; patches justified only by a custom toolchain, FreeBSD linker or tool bug (e.g., `NO_CMAKE_FIND_ROOT_PATH` additions, backported CMake modules).
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#48512](https://github.com/microsoft/vcpkg/pull/48512#issuecomment-3614902616), [#25761](https://github.com/microsoft/vcpkg/pull/25761#discussion_r920705181)

### BLD-014: Keep dllexport macros private to the library build

- **Rule:** Macros that switch declarations to `__declspec(dllexport)` (`FOO_EXPORTS`, `FOO_BUILD_DLL`) must be PRIVATE compile definitions of the library. Exporting them through PUBLIC or INTERFACE definitions or installed metadata gives consumers dllexport instead of dllimport.
- **Check:** `target_compile_definitions(<lib> PUBLIC|INTERFACE ...EXPORTS...)` in patches or port-supplied CMakeLists; export macros in exported `INTERFACE_COMPILE_DEFINITIONS`; installed headers with unguarded dllexport.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#34517](https://github.com/microsoft/vcpkg/pull/34517#discussion_r1361183615), [#33679](https://github.com/microsoft/vcpkg/pull/33679#discussion_r1357831771)

### BLD-015: Keep release debug information; don't swap /Z7 for /Zi

- **Rule:** Don't strip release debug information or replace MSVC `/Z7` with `/Zi` to shrink static libraries; users need to symbolize crash dumps even from release builds. vcpkg uses `/Z7` deliberately because static-library builds mishandle PDBs (colliding default names such as `vc140.pdb`); `/Zi` is acceptable only with unique per-target PDB names (`/Fd`) and the PDBs installed beside `lib/*.lib` and `debug/lib/*.lib`.
- **Check:** `string(REPLACE "/Z7" "/Zi" ...)`, `CMAKE_MSVC_DEBUG_INFORMATION_FORMAT` changes or debug-info stripping in portfiles or patches; static packages lacking `.pdb` files next to their `.lib` files after such changes.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#53025](https://github.com/microsoft/vcpkg/pull/53025#issuecomment-5060170126), [#53401](https://github.com/microsoft/vcpkg/pull/53401#discussion_r3779573380)

### BLD-016: Compile single-TU implementations of stb-style libraries in the port

- **Rule:** For libraries whose headers require exactly one translation unit to define an implementation macro (e.g., `*_IMPLEMENTATION` in stb-style or metal-cpp headers), the port should compile that implementation once into an installed library rather than telling consumers to define it, unless upstream documents a different usage model. If two dependents in one link each define it, linking fails.
- **Check:** Usage text or docs telling consumers to `#define *_IMPLEMENTATION` in one source file; new header-only ports of such libraries.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** PRs: [#51353](https://github.com/microsoft/vcpkg/pull/51353#discussion_r3134128791), [#24804](https://github.com/microsoft/vcpkg/pull/24804#discussion_r886047872)

### BLD-017: Never force past duplicate-symbol link errors with /FORCE:MULTIPLE

- **Rule:** Don't add `/FORCE:MULTIPLE` (via patches, `target_link_options` or flags) to make builds, typically static Windows ones, link; forcing past duplicate definitions is almost certainly unsafe. Describe the actual linker error and fix the duplicate definitions or dependency setup instead.
- **Check:** grep portfile.cmake and patches for `/FORCE:MULTIPLE` or similar duplicate-symbol suppressions.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#50698](https://github.com/microsoft/vcpkg/pull/50698#discussion_r3003917526)

### BLD-018: Build with upstream's own build system, not vcpkg replacements

- **Rule:** Use upstream's build system (CMake when upstream offers several), configured with options and minimal patches, rather than a vcpkg-written CMakeLists.txt, a CMake-only fork or a wrapper that just runs make/nmake; replacements must be resynchronized on every update. Where the guide's allowance for rewriting unusual build systems into CMake applies, keep the file minimal and concrete (globbed sources, version from the portfile) and match upstream's install layout, names and interface.
- **Check:** New `ports/<port>/CMakeLists.txt` copied into `SOURCE_PATH` although upstream ships CMake, Meson or autotools; `vcpkg_install_msbuild` despite upstream CMake; hard-coded `VERSION`, GNUInstallDirs boilerplate, helper scripts or custom platform-suffix logic in port-supplied build files.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Prefer using CMake](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#prefer-using-cmake); [Maintainer guide: Prefer options over patching](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#prefer-options-over-patching); PRs: [#48052](https://github.com/microsoft/vcpkg/pull/48052#issuecomment-3477477118), [#48344](https://github.com/microsoft/vcpkg/pull/48344#issuecomment-3559805456)

### BLD-019: Consume dependencies through canonical find_package and pkg-config interfaces

- **Rule:** In build scripts and patches, find dependencies via canonical interfaces: `find_package` with the exact installed package name (REQUIRED when mandatory, imported targets, inside the owning feature's condition) and pkg-config via `IMPORTED_TARGET`, `<PREFIX>_LINK_LIBRARIES` or `PKG_CHECK_MODULES`, using only the include paths and flags they provide. Avoid `include(Find<X>)`, `find_library` chains and hard-coded HINTS, which bypass vcpkg wrappers and transitive static requirements, and keep `VCPKG_*` variables and vcpkg paths out of upstream code.
- **Check:** `include(Find*)`; `${X_LIBRARIES}` from `pkg_check_modules`; `AC_SEARCH_LIBS` with hard-coded or debug-suffixed names; case-mismatched CONFIG package names; `#include` paths not backed by the dependency's `.pc` Cflags or `INTERFACE_INCLUDE_DIRECTORIES`; patches referencing `VCPKG_*` or vcpkg_installed.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#40597](https://github.com/microsoft/vcpkg/pull/40597#issuecomment-2348010550), [#49802](https://github.com/microsoft/vcpkg/pull/49802#issuecomment-3851268234)

### BLD-020: Disable warnings-as-errors and never add warning flags

- **Rule:** Ports must not add warning levels (`/W4`, `-Wall`) or warnings-as-errors (`/WX`, `-Werror`); turn off upstream `-Werror` via an option or minimal patch and keep existing no-werror patches even when current CI passes, because vcpkg's toolchain matrix and future compilers add warnings users can't fix. Prefer disabling `-Werror` over patching code or silencing individual (e.g., deprecation) warnings, citing the warnings when they may reveal real bugs.
- **Check:** `-Werror`, `/WX`, `CMAKE_COMPILE_WARNING_AS_ERROR`, `*_WARNINGS_AS_ERRORS=ON` or `/W4` in upstream files, patches or logs (C2220 "warning treated as an error"); PRs removing disable-werror patches or adding `-Wno-*` while `-Werror` stays.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#54692](https://github.com/microsoft/vcpkg/pull/54692#issuecomment-6427206457), [#41877](https://github.com/microsoft/vcpkg/pull/41877#discussion_r1824106562)

### BLD-021: Drive autotools, make and nmake builds through vcpkg helpers

- **Rule:** Build configure/make/nmake projects with vcpkg's helpers (`vcpkg_make_configure`/`vcpkg_make_install`, `vcpkg_configure_make` in older ports, `vcpkg_install_nmake`), wrapping plain Makefiles if needed, so triplet compilers, flags, CRT and both build types reach the build. Don't hand-roll make invocations or per-configuration loops, guess `--host`/`--cross-prefix`, or override helper-set `CC`/`CCAS`/`CXX` with `VCPKG_DETECTED_*` values; pass `ac_cv_*` cache variables to bypass broken configure checks.
- **Check:** `execute_process`/`vcpkg_execute_*` running configure, make or nmake directly; `ENV{CC}` assignments; options such as `CCAS=${VCPKG_DETECTED_CMAKE_C_COMPILER}`; triplet flags missing from build logs; manual clean steps between configurations.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#29374](https://github.com/microsoft/vcpkg/pull/29374#discussion_r1166280636), [#46287](https://github.com/microsoft/vcpkg/pull/46287#discussion_r2186772620)

### BLD-022: Fix configuration races at their cause, not by serializing

- **Rule:** vcpkg configures debug and release in parallel from one source tree: if upstream's configure writes into it and that can't be turned off, add `DISABLE_PARALLEL_CONFIGURE`, and patch per-configuration state or outputs written there or to parent directories (`add_subdirectory(../x)`) into the binary directory; use unique temporary paths. Use `DISABLE_PARALLEL`, `-j1`, `DISABLE_PARALLEL_INSTALL` or `WINDOWS_USE_MSBUILD` only for a diagnosed race or genuine project requirement, since blanket serialization hides the real bug.
- **Check:** `configure_file`/`file(WRITE)` into `CMAKE_SOURCE_DIR`; "Permission denied" or missing-file configure errors; intermittent failures on many-core machines; fixed `/tmp` or mount-point paths; `DISABLE_PARALLEL*`, `-j1` or `WINDOWS_USE_MSBUILD` without a stated diagnosis.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_cmake_configure: DISABLE_PARALLEL_CONFIGURE](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_cmake_configure#disable_parallel_configure); PRs: [#46399](https://github.com/microsoft/vcpkg/pull/46399#issuecomment-3066513700), [#49397](https://github.com/microsoft/vcpkg/pull/49397#pullrequestreview-3748120825)

### BLD-023: Patch autotools inputs and regenerate them through the helper

- **Rule:** Patch `configure.ac`, `Makefile.am` or m4 inputs rather than generated `configure` or `Makefile.in`, and let the helper regenerate them (`AUTORECONF` in `vcpkg_make_configure`, `AUTOCONFIG` in `vcpkg_configure_make`) instead of running autoreconf yourself; keep that option while such patches exist, or the patch has no effect or make regenerates unpredictably. Without `AUTOCONFIG`, `vcpkg_configure_make` cross builds need `DETERMINE_BUILD_TRIPLET`; MSVC `ar-lib`/`compile` probe failures need `USE_WRAPPERS`.
- **Check:** Patch hunks editing `configure` or `Makefile.in`; `autoreconf`/`autogen.sh` run via `vcpkg_execute_*`; `AUTORECONF`/`AUTOCONFIG` removed while `*.am` or `configure.ac` patches remain; "ar-lib: unknown action specified" in Windows static logs.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_configure_make: AUTOCONFIG](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_configure_make#autoconfig); [vcpkg_make_configure: AUTORECONF](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_make_configure#autoreconf); [vcpkg_configure_make: USE_WRAPPERS](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_configure_make#use_wrappers); PRs: [#31607](https://github.com/microsoft/vcpkg/pull/31607#discussion_r1231898777), [#39050](https://github.com/microsoft/vcpkg/pull/39050#discussion_r1661414104)

### BLD-024: Pass extra flags via options or targets, not VCPKG_*_FLAGS

- **Rule:** Don't append defines or compiler options (e.g., `/Zc:preprocessor`) to `VCPKG_C_FLAGS`/`VCPKG_CXX_FLAGS` in a portfile; pass them as project configure options or patch them onto the affected target, since custom toolchains need not forward vcpkg flag variables. When make builds need extra `CFLAGS`/`CXXFLAGS`/`LDFLAGS`, extend the existing value instead of replacing it, and never embed unquoted paths (`-I${CURRENT_PACKAGES_DIR}/include`) in flag strings, which breaks vcpkg roots containing spaces.
- **Check:** `set(VCPKG_C(XX)_FLAGS ...)` or `string(APPEND VCPKG_*_FLAGS ...)` in portfile.cmake; `CFLAGS=`/`CXXFLAGS=` options dropping the previous value; `-I${`, `-L${` or `-isystem ${` inside `*_FLAGS`; verify by installing from a path with spaces.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Prefer patching over overriding VCPKG_<VARIABLE> values](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#prefer-patching-over-overriding-vcpkg_variable-values); PRs: [#53264](https://github.com/microsoft/vcpkg/pull/53264#discussion_r3808817188), [#50278](https://github.com/microsoft/vcpkg/pull/50278#pullrequestreview-3890794473)

### BLD-025: Leave position-independent code to the vcpkg toolchain

- **Rule:** Don't add `-fPIC`, `--with-pic`, `CMAKE_POSITION_INDEPENDENT_CODE` or "fpic" features to individual ports; the vcpkg toolchain and triplet already control PIC and the make helpers forward it in `CFLAGS`, so a build ignoring `CFLAGS` should be fixed to honor them. "Recompile with -fPIC" relocation errors usually stem from assembler objects or linking static libraries into shared ones; fix that root cause.
- **Check:** `-fPIC`, `--with-pic` or `CMAKE_POSITION_INDEPENDENT_CODE` in portfile options, patches or new features, especially added in response to `R_X86_64_PC32` relocation errors.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#18610](https://github.com/microsoft/vcpkg/pull/18610#issuecomment-1126548089), [#38984](https://github.com/microsoft/vcpkg/pull/38984#issuecomment-2135709479)

### BLD-026: Link libm and Apple frameworks directly, not via find_library

- **Rule:** Link `m` unconditionally on UNIX (or via implicit link directories) instead of making it depend on `find_library(m)` or `check_library_exists`, which fail in Linux cross builds such as arm64-linux and can drop `m` from static consumers' link interface. Link standard Apple frameworks as `-framework <Name>` instead of locating them with `find_library`.
- **Check:** Upstream linking `m` only when `find_library` succeeds; undefined math symbols (e.g., `atan2`) on arm64-linux or in static dependents; CMake configs or `.pc` files lacking `m`; `find_library` calls for CoreFoundation or IOKit in patches.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#52086](https://github.com/microsoft/vcpkg/pull/52086#issuecomment-4579554243), [#50514](https://github.com/microsoft/vcpkg/pull/50514#issuecomment-4384682786)

### BLD-027: Lower inflated cmake_minimum_required when newer features are unused

- **Rule:** If upstream requires a newer CMake than vcpkg provides, check whether any newer feature is actually used; if not, lower `cmake_minimum_required` with a patch (and suggest it upstream) so the port builds with vcpkg's CMake.
- **Check:** Configure error "CMake 3.xx or higher is required" or a `cmake_minimum_required` above vcpkg's bundled CMake version.
- **Severity:** advisory · **Scope:** all
- **Sources:** PRs: [#46137](https://github.com/microsoft/vcpkg/pull/46137#issuecomment-3189817595)

## LAY: Installed layout and post-build checks

### LAY-001: Fix post-build check failures instead of suppressing them

- **Rule:** Post-build validation problems usually reveal portfile or upstream-build bugs and fail curated-registry CI even though they are only warnings locally; fix each at its root by patching the upstream build or rearranging files in portfile.cmake. Enable a `VCPKG_POLICY_*` only when the flagged situation is intended by design (e.g., `EMPTY_INCLUDE_FOLDER` for a tool-only port, `EMPTY_PACKAGE` for a metaport) and comment why; never use one to silence a defect.
- **Check:** "Found N post-build check problem(s)" or `POST_BUILD_CHECKS_FAILED` in local or CI logs; new `set(VCPKG_POLICY_... enabled)` lines and whether their stated reason holds.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Policies](https://learn.microsoft.com/vcpkg/reference/policies); PRs: [#48264](https://github.com/microsoft/vcpkg/pull/48264#pullrequestreview-3467590773), [#48052](https://github.com/microsoft/vcpkg/pull/48052#pullrequestreview-3408172450)

### LAY-002: Never embed absolute build-machine paths in installed files

- **Rule:** Installed files (headers, CMake and pkg-config files, scripts and launchers, data or config files, binaries) must not contain absolute paths into packages/, buildtrees/, installed/, downloads/, or producer-machine compiler runtimes. Fix the generation (config fixup, `vcpkg_replace_string`, upstream options) instead of setting `VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK`; only deliberate system-library paths in `.pc` `Libs` or non-essential fallback search paths may remain. Such paths break every binary-cache restore.
- **Check:** Post-build "There should be no absolute paths ... in an installed package"; grep installed text files and `strings` of binaries for the vcpkg root, buildtrees, or CI paths such as `D:\b` or `/mnt/vcpkg-ci`; the skip policy in the diff.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Policies: VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_skip_absolute_paths_check); PRs: [#52688](https://github.com/microsoft/vcpkg/pull/52688#pullrequestreview-4621978966), [#46422](https://github.com/microsoft/vcpkg/pull/46422#issuecomment-3400357822)

### LAY-003: Install executables under tools/<port>, never in bin

- **Rule:** Everything in bin/ and debug/bin is treated as a DLL (or PDB) consumers deploy, so executables, including tests and Unix binaries, belong in `tools/<port>`, never bin/ or include/. Let upstream install them, then relocate with `vcpkg_copy_tools(TOOL_NAMES ... AUTO_CLEAN)`, which also copies their DLLs, rather than copying from buildtrees or pointing a bindir that also receives DLLs at tools/; if the build already installs tools under `tools/<port>`, don't add code just to move them. Omit unneeded executables or gate them behind a `tools` feature.
- **Check:** Post-build "The following EXEs were found in /bin or /debug/bin"; `VCPKG_POLICY_ALLOW_EXES_IN_BIN`; `file(REMOVE ... *.exe)` deleting wanted tools, copies from `${CURRENT_BUILDTREES_DIR}`, `--bindir` pointed at tools/, or tool copying not conditioned on the feature that builds the tool.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: tools](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-tools); [Policies: VCPKG_POLICY_ALLOW_EXES_IN_BIN](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_allow_exes_in_bin); [vcpkg_copy_tools](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_copy_tools); PRs: [#35439](https://github.com/microsoft/vcpkg/pull/35439#discussion_r1412757286), [#44100](https://github.com/microsoft/vcpkg/pull/44100#issuecomment-2704938183)

### LAY-004: Never install files another port owns

- **Rule:** Every installed file, library, and symbol must have one owning port, because any combination of ports and features must install together: don't install vendored copies of other ports, system SDK libraries (`opengl32.lib`), headers owned elsewhere (`GL/gl.h`), shared aggregate caches (`gschemas.compiled`), or a CMake package name another port uses. Devendor, rename minimally into a port-specific path, or keep the conflicting feature non-default; a port that inevitably conflicts generally isn't accepted.
- **Check:** CI "The following files are already installed ... and are in conflict" or `FILE_CONFLICTS`; `vcpkg owns <file>` and other ports' file lists; include/, lib/, or share/<pkg> entries named after other projects.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Unique port attribution rule](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#unique-port-attribution-rule); [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); PRs: [#51509](https://github.com/microsoft/vcpkg/pull/51509#pullrequestreview-4215893724), [#49868](https://github.com/microsoft/vcpkg/pull/49868#issuecomment-3874770372)

### LAY-005: Install headers in upstream's documented include layout

- **Rule:** Install public headers under include/ exactly where upstream's install rules and documentation put them, so the documented `#include` form resolves from `<triplet>/include` alone. Don't add, drop, or rename subdirectories (versioned roots such as include/foo-1.2, vcpkg-invented prefixes), park headers in share/, or rely on extra or widened include roots in targets or `.pc` Cflags; deviate only to resolve name conflicts, documenting the include form. Pre-existing deviations become follow-ups.
- **Check:** Compare the installed include/ tree with upstream install rules, docs, and samples; compile each public header with only `-I<triplet>/include` in Release and Debug, and inspect `INTERFACE_INCLUDE_DIRECTORIES` and `.pc` Cflags for added subdirectories or a bare include root.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: include](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-include); PRs: [#25108](https://github.com/microsoft/vcpkg/pull/25108#issuecomment-1150491324), [#32660](https://github.com/microsoft/vcpkg/pull/32660#issuecomment-1654592758)

### LAY-006: Namespace generic or reserved header names under include/<port>

- **Rule:** Headers or top-level include directories with reserved or very common names (e.g., `err.h`, `time.h`, `getopt.h`, `uuid.h`, `config.hh`, `Utils/`) must not sit at the include root; move them under `include/<port>/` and adjust exported include directories and usage to match. Likewise keep tools and data in port-named paths such as `tools/<port>` and `share/<port>`. Root-level generic names clobber system headers or make ports mutually incompatible.
- **Check:** Restricted-header post-build failures; new generic names directly in include/ or as top-level include directories; other ports' file lists containing the same names.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: include](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-include); [Maintainer guide: Unique port attribution rule](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#unique-port-attribution-rule); PRs: [#32340](https://github.com/microsoft/vcpkg/pull/32340#pullrequestreview-1512058639), [#51353](https://github.com/microsoft/vcpkg/pull/51353#discussion_r3140609431)

### LAY-007: Make installed public headers compile and link standalone

- **Rule:** Every installed public header must compile from the installed tree with MSVC and GCC/Clang on supported triplets, or the package is unusable: everything it includes must be installed (no `../` paths into the source tree, bundled `external/` headers, or backslash includes), and its declarations must be implemented by the installed libraries. Install headers of optional components only with the feature that builds them; pre-existing defects found during updates become follow-ups.
- **Check:** Compile a consumer that includes each public or umbrella header with only `<triplet>/include` (also with default features disabled) and links a symbol on Windows and Linux; grep installed headers for `#include "../`, `external/`, `third_party/`, or backslashes; flag exported include directories requiring extra `include/<subdir>` paths full of generic names; watch for C1083 or unresolved externals.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#54997](https://github.com/microsoft/vcpkg/pull/54997#pullrequestreview-5867727968), [#54305](https://github.com/microsoft/vcpkg/pull/54305#pullrequestreview-5552312731)

### LAY-008: Put DLLs in bin with matching import libraries

- **Rule:** On Windows, DLLs go to bin/ and debug/bin/ (never lib/), each exporting symbols and paired with an import library in lib/ that references the DLL's actual name; dynamic builds must really produce DLLs, and static triplets must produce none (a /MT plugin DLL embeds its own CRT). On other platforms, shared libraries and their version symlinks stay together in lib/. The loader, app-local deployment, and consumers depend on this layout.
- **Check:** Post-build messages about DLLs in /lib, DLLs without libs or exports, or DLLs in a static build; dynamic file lists with lib/*.lib but no bin/*.dll; `install(TARGETS)` lacking `RUNTIME DESTINATION`; dangling .so symlinks; consumer LNK1107 or 0xC0000135.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: bin](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-bin); [Policies: VCPKG_POLICY_ALLOW_DLLS_IN_LIB](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_allow_dlls_in_lib); [Policies: VCPKG_POLICY_DLLS_WITHOUT_LIBS](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_dlls_without_libs); [Policies: VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_dlls_in_static_library); PRs: [#36518](https://github.com/microsoft/vcpkg/pull/36518#issuecomment-1923074328), [#54093](https://github.com/microsoft/vcpkg/pull/54093#pullrequestreview-5325028910)

### LAY-009: Remove debug/include and debug/share; keep headers configuration-independent

- **Rule:** After config and pkg-config fixups, delete `${CURRENT_PACKAGES_DIR}/debug/include` and `debug/share`, moving anything important first, instead of enabling `VCPKG_POLICY_ALLOW_DEBUG_INCLUDE` or `ALLOW_DEBUG_SHARE`. Because only the release include/ is kept, installed headers must not encode Debug- or Release-specific values; fix them in the providing port, or mark the feature unsupported, rather than forcing consumers to build release-only.
- **Check:** Post-build "/debug/include should not exist" or "/debug/share should not exist"; no `file(REMOVE_RECURSE)` of them after `vcpkg_cmake_config_fixup`; generated config headers that differ between debug and release builds.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Policies: VCPKG_POLICY_ALLOW_DEBUG_INCLUDE](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_allow_debug_include); [Policies: VCPKG_POLICY_ALLOW_DEBUG_SHARE](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_allow_debug_share); PRs: [#42347](https://github.com/microsoft/vcpkg/pull/42347#pullrequestreview-2459657059), [#31986](https://github.com/microsoft/vcpkg/pull/31986#issuecomment-1692655074)

### LAY-010: Remove empty directories explicitly after checking why

- **Rule:** Packages must not contain empty directories, which several binary-cache providers and git cannot represent. Delete known empty directories explicitly with `file(REMOVE_RECURSE ...)` rather than enabling `VCPKG_POLICY_ALLOW_EMPTY_FOLDERS` or removing them generically, and first check whether the emptiness reveals a bug, such as nothing being built on that platform.
- **Check:** Post-build "There should be no empty directories"; `VCPKG_POLICY_ALLOW_EMPTY_FOLDERS` in portfile.cmake; empty include/ or lib/ hinting at a failed build.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Policies: VCPKG_POLICY_ALLOW_EMPTY_FOLDERS](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_allow_empty_folders); PRs: [#50427](https://github.com/microsoft/vcpkg/pull/50427#issuecomment-4053190170), [#40126](https://github.com/microsoft/vcpkg/pull/40126#issuecomment-2319162231)

### LAY-011: Keep installed packages relocatable and self-contained

- **Rule:** Compute installed lookups relative to the installed file (`$0`, `${CMAKE_CURRENT_LIST_DIR}`, `${prefix}`, `$ORIGIN` RPATHs, with correct depth for debug copies) or leave them unset where upstream allows; never resolve them against the current directory, an attack vector, or bake in `HOST_TRIPLET`. Write nothing outside `${CURRENT_PACKAGES_DIR}` (e.g., `export(PACKAGE)`), since only it is restored from binary caches, and don't ship components that can't be relocated, such as pip.
- **Check:** Prefix computations in installed scripts, including tools/<port>/debug copies; RUNPATH entries via `readelf -d`; relative default directories in configure options or patches; `export(PACKAGE)` or home/system-directory writes; `HOST_TRIPLET` in installed configs.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Policies: VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_skip_absolute_paths_check); PRs: [#41527](https://github.com/microsoft/vcpkg/pull/41527#discussion_r1802254661), [#24076](https://github.com/microsoft/vcpkg/pull/24076#issuecomment-1125387641)

### LAY-012: Keep upstream binary names; rename only through the build

- **Rule:** Keep upstream's names for libraries, DLLs, and tools, including debug postfixes and tool aliases; don't add or strip postfixes, and a vcpkg-provided CMakeLists should use none. Rename only to unify static/shared variants or resolve an actual clash such as a generic `common.lib`, preferably with upstream, by patching `OUTPUT_NAME` (guarded to the affected toolchain), never via `file(RENAME)` after install, because configs, `.pc` files, and import libraries reference the original names.
- **Check:** `file(RENAME)` of .lib/.a/.so/.dll files; patches touching `OUTPUT_NAME`, `DEBUG_POSTFIX`, or `EXPORT_NAME`; executables or aliases dropped from tool lists; installed names versus upstream's per-platform names.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not rename binaries outside the names given by upstream](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-rename-binaries-outside-the-names-given-by-upstream); PRs: [#51725](https://github.com/microsoft/vcpkg/pull/51725#issuecomment-4443459137), [#23658](https://github.com/microsoft/vcpkg/pull/23658#discussion_r832549266)

### LAY-013: Install libraries directly in lib/ and debug/lib/

- **Rule:** Install static and import libraries directly in lib/ and debug/lib/, not in private, versioned, or configuration-named subdirectories such as lib/coco-4.7.1 or lib/Release; only manual-link, pkgconfig, and plugin subdirectories are standard. Confirm compiled ports actually install their libraries in both configurations; a successful `cmake --install` elsewhere isn't proof. Non-CMake consumers search only the triplet's library roots.
- **Check:** Package file lists with .lib/.a/.so under lib/<subdir>/ or configuration-named directories; missing lib/ contents; a direct-link consumer using only `<triplet>/lib` failing.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: lib](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-lib); PRs: [#52625](https://github.com/microsoft/vcpkg/pull/52625#pullrequestreview-4621945384), [#50240](https://github.com/microsoft/vcpkg/pull/50240#pullrequestreview-3878626187)

### LAY-014: Produce matching debug and release binaries

- **Rule:** Library ports must install debug and release binaries in matching numbers unless the triplet builds release only. Don't satisfy the check by copying release libraries into debug/, which carries the wrong CRT, or by enabling `VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES` without a real reason.
- **Check:** Post-build "Mismatching number of debug and release binaries"; portfile copying lib/ into debug/lib; the policy in the diff.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Policies: VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_mismatched_number_of_binaries); PRs: [#24804](https://github.com/microsoft/vcpkg/pull/24804#issuecomment-1178632049), [#24914](https://github.com/microsoft/vcpkg/pull/24914#pullrequestreview-1160907490)

### LAY-015: Install pkg-config files in lib/pkgconfig and keep them

- **Rule:** `.pc` files belong in lib/pkgconfig and debug/lib/pkgconfig, or in share/pkgconfig only when configuration-independent (never both, never platform-specific locations such as libdata/pkgconfig), and `vcpkg_fixup_pkgconfig` must run. Header-only ports that delete lib/ must keep their `.pc` files. Misplaced or deleted files aren't found by pkgconf.
- **Check:** Installed `*.pc` outside those directories or in both share/ and lib/; `file(REMOVE_RECURSE .../lib)` after `.pc` installation; pkgconfig post-build warnings; pkgconf lookups in Release and Debug.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: pkgconfig](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-pkgconfig); [Policies: VCPKG_POLICY_SKIP_PKGCONFIG_CHECK](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_skip_pkgconfig_check); PRs: [#55112](https://github.com/microsoft/vcpkg/pull/55112#pullrequestreview-6001930232), [#55004](https://github.com/microsoft/vcpkg/pull/55004#pullrequestreview-5867878585)

### LAY-016: Install only the headers upstream exposes

- **Rule:** Install exactly the public API headers upstream installs; don't copy extra or private implementation headers (e.g., `*_p.h`, internal detail headers) from the source tree or add `install()` rules for them because some consumer wants them. If private headers must ship, keep them out of the include root. Upstream maintainers decide what the package exposes.
- **Check:** `file(INSTALL)` or `file(COPY)` of source-tree headers beyond upstream's install rules; patches adding install rules for private headers; newly installed internal headers not referenced by the public API.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: include](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-include); PRs: [#35143](https://github.com/microsoft/vcpkg/pull/35143#issuecomment-1984691417), [#52580](https://github.com/microsoft/vcpkg/pull/52580#issuecomment-4796184822)

### LAY-017: Place libraries with conflicting symbols in manual-link

- **Rule:** Libraries that define `main`, `malloc`, or other symbols defined elsewhere go to `lib/manual-link` and `debug/lib/manual-link`, while their DLLs stay in bin/. Auto-linking integrations such as MSBuild would otherwise link them into every consumer.
- **Check:** `*main*.lib`/`.a`, allocator replacements, or duplicate-symbol libraries directly in lib/.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Place conflicting libs in a manual-link directory](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#place-conflicting-libs-in-a-manual-link-directory)

### LAY-018: Ship release-only tools unless debug tools are runtime-needed

- **Rule:** Install only release executables by default, since debug tools mostly add build time: `vcpkg_copy_tools(... AUTO_CLEAN)` drops debug copies, and tool-only ports should set `VCPKG_BUILD_TYPE release`. Ship debug executables only when the debug library launches them at runtime (e.g., a daemon), and then they must link the debug libraries; reviewers don't block on tools/<port>/debug versus debug/tools/<port>.
- **Check:** tools/<port>/debug or debug/tools/<port> without a runtime need; tool-only ports building both configurations; debug-postfixed tools left in debug/bin; debug tools resolving release libraries.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Installation tree layout: tools](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-tools); PRs: [#54764](https://github.com/microsoft/vcpkg/pull/54764#discussion_r4518487456), [#37964](https://github.com/microsoft/vcpkg/pull/37964#issuecomment-2075750162)

### LAY-019: Make installed tools work from the installed tree

- **Rule:** Retained tools must run from `installed/<triplet>/tools/<port>` in every configuration shipped: deploy all imported DLLs with `vcpkg_copy_tools` or `vcpkg_copy_tool_dependencies` (not deprecated helpers), install config files, script modules, and resource directories where each relocated copy looks, and keep the executable bit. Test without the build toolchain on PATH; packaging must not lose functionality upstream advertises.
- **Check:** Run installed tools (e.g., `--version`) from another working directory with the compiler directory removed from PATH; look for 0xC0000135, "cannot open file", or `ModuleNotFoundError`, and compare with upstream's archive layout.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Installation tree layout: tools](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-tools); [Maintainer guide: Avoid deprecated helper functions](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-deprecated-helper-functions); PRs: [#54093](https://github.com/microsoft/vcpkg/pull/54093#pullrequestreview-5397453930), [#53811](https://github.com/microsoft/vcpkg/pull/53811#discussion_r3963094186)

### LAY-020: Install runtime-loaded plugins and data where loaders search

- **Rule:** Put runtime-loaded plugins, modules, and data where their loader looks, or they silently go unfound: `plugins/<group>` by default, Qt's plugin directory for Qt-loaded plugins, `${PYTHON3_SITE}` for Python bindings, and conventional data directories such as share/glib-2.0, not lib/ or bin/. Moved plugins must still get post-build linting and app-local deployment; optional pieces vcpkg can't deploy, such as daemons, may be dropped.
- **Check:** Plugin install options (e.g., `KDE_INSTALL_PLUGINDIR`) versus how the library loads plugins; plugin DLLs in lib/ or bin/; Python modules under lib/pythonX.Y instead of `${PYTHON3_SITE}`; a consumer test showing the plugin is found.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Installation tree layout: plugins](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-plugins); [Installation tree layout: share](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-share); PRs: [#54780](https://github.com/microsoft/vcpkg/pull/54780#discussion_r4489140118), [#50922](https://github.com/microsoft/vcpkg/pull/50922#discussion_r3067403200)

### LAY-021: Don't delete bin or lib directories to silence checks

- **Rule:** The post-build-suggested static-only `file(REMOVE_RECURSE bin debug/bin)` is acceptable only when those directories are empty or hold nothing users need. First find out why they exist: executables belong in tools/ via `vcpkg_copy_tools(AUTO_CLEAN)`, and DLLs mean linkage isn't controlled. Never delete lib/ or debug/lib wholesale; blind deletions can mask a completely broken package.
- **Check:** Static-only removal of bin/ or lib/ in portfile.cmake; what the static build placed in bin/ (executables, DLLs, scripts) per logs or file lists; a resulting package without the expected libraries.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#52310](https://github.com/microsoft/vcpkg/pull/52310#discussion_r3400131572), [#44447](https://github.com/microsoft/vcpkg/pull/44447#issuecomment-2741087109)

### LAY-022: Don't install build-system files, informational docs, or demo data

- **Rule:** Install only package content: no build-system inputs or leftovers (Makefile.am/.in, meson.build, CMakeLists.txt, props or build.cfg files), no informational files such as AUTHORS, NEWS, or README, and no demo, test, or benchmark data unless a feature needs it. Prefer fixing the install rule or helper that copies them; removing them after install is accepted. Avoid installing .c/.cpp sources as fake header-only libraries (tolerated in existing ports).
- **Check:** Installed file lists with *.am, *.in, meson.build, CMakeLists.txt, AUTHORS/NEWS/README, or example and test data under include/, lib/, or share/<port>; .c/.cpp files under include/.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not build tests/docs/examples by default](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-build-testsdocsexamples-by-default); PRs: [#28352](https://github.com/microsoft/vcpkg/pull/28352#discussion_r1049419509), [#51728](https://github.com/microsoft/vcpkg/pull/51728#discussion_r3269784458)

## INT: Consumer integration (CMake and pkg-config)

### INT-001: Call find_dependency for every exported link dependency

- **Rule:** An installed CMake config must `find_dependency` every package whose imported targets appear in its exported link interfaces, including `$<LINK_ONLY:...>` dependencies of static libraries, Threads, and feature- or platform-specific dependencies, so `find_package(<pkg> CONFIG REQUIRED)` works alone. Use the package that actually provides each target (`EXPAT::EXPAT` versus `expat::expat`), patching upstream's config template when it omits calls. Consumers cannot know a package's private dependencies.
- **Check:** Compare `INTERFACE_LINK_LIBRARIES` in `share/<pkg>/*Targets.cmake` with the config's `find_dependency` calls and configure a minimal consumer on static and dynamic triplets, watching for "The link interface of target ... contains: X::Y but the target was not found".
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist: c000010](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000010); PRs: [#35781](https://github.com/microsoft/vcpkg/pull/35781#discussion_r1637697330), [#51918](https://github.com/microsoft/vcpkg/pull/51918#discussion_r3306966178)

### INT-002: Write find_dependency calls that mirror the build's lookups

- **Rule:** Include `CMakeFindDependencyMacro` and call `find_dependency`, not `find_package`, before including the targets file, without `REQUIRED` or `QUIET` so the caller's choice propagates; wrappers and Find modules may instead use guarded `find_package(... REQUIRED)`. Mirror the build's package name, mode, components and feature, platform or compiler conditions (e.g., OpenMP), require nothing the installed build doesn't use, and update the config whenever a patch changes a lookup.
- **Check:** Look for `find_dependency(... REQUIRED)`, `find_package` in installed configs, calls placed after `include(<pkg>Targets.cmake)`, "Unknown CMake command find_dependency", unconditional lookups of optional-feature dependencies, and patched `find_package` calls without a matching config change.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#39255](https://github.com/microsoft/vcpkg/pull/39255#pullrequestreview-2113523641), [#53099](https://github.com/microsoft/vcpkg/pull/53099#pullrequestreview-4816095334)

### INT-003: Name vcpkg-authored CMake exports `unofficial-<port>`

- **Rule:** CMake packages and targets that upstream doesn't provide or hasn't merged must be installed as `unofficial-<port>` in `share/unofficial-<port>`, with targets in `unofficial::<port>::`, because obvious names create vcpkg lock-in and collide with later official exports. Backports of exports upstream already accepted and names upstream already established keep official names. Older ports that predate the rule change names only with compatibility shims.
- **Check:** New `install(EXPORT)`, `NAMESPACE` or `*Config.cmake(.in)` in patches or port-supplied CMakeLists; compare with upstream's repository and verify the installed `share/unofficial-<port>` directory and `unofficial::` target prefix.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Add CMake exports in an unofficial- namespace](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#add-cmake-exports-in-an-unofficial--namespace); PRs: [#35579](https://github.com/microsoft/vcpkg/pull/35579#issuecomment-1848428064), [#50120](https://github.com/microsoft/vcpkg/pull/50120#discussion_r2874560031)

### INT-004: Install CMake configs where find_package looks for them

- **Rule:** Install each config as `share/<lowercase-package>/<Pkg>Config.cmake` or `<pkg>-config.cmake`, named for the package users pass to `find_package`, which need not match the port name; separate packages need separate `share/` directories. Don't add alias configs for the port name or move configs into unsupported or version-suffixed directories. CMake only searches directories and files matching the requested name.
- **Check:** Compare `share/` directory names with config file names and run the documented `find_package(<Pkg> CONFIG REQUIRED)` from a consumer; look for "Could not find a package configuration file provided by" and portfile-written `<port>Config.cmake` forwarders.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: CMake](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-cmake); PRs: [#54080](https://github.com/microsoft/vcpkg/pull/54080#pullrequestreview-5313176294), [#48276](https://github.com/microsoft/vcpkg/pull/48276#discussion_r2529541605)

### INT-005: Run vcpkg_cmake_config_fixup on the real installed package

- **Rule:** When the build installs a CMake config package, call `vcpkg_cmake_config_fixup` with `PACKAGE_NAME` equal to the `find_package` name and `CONFIG_PATH` where upstream installs it, so Config, ConfigVersion and Targets files land together and debug and release are merged. A Targets file without a Config is not a package: fix the install or drop the call instead of pre-moving files or forcing release-only builds.
- **Check:** Configs left in `lib/cmake` or `cmake/` (lib-cmake merge warning); fixup errors that a directory "does not exist"; `set(VCPKG_BUILD_TYPE release)` or `file(RENAME)` of configs before the call; `*Config.cmake` and `*Targets.cmake` in different directories.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: CMake](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-cmake); [vcpkg_cmake_config_fixup](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_cmake_config_fixup); [Policies: VCPKG_POLICY_SKIP_LIB_CMAKE_MERGE_CHECK](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_skip_lib_cmake_merge_check); PRs: [#48738](https://github.com/microsoft/vcpkg/pull/48738#issuecomment-3640526350), [#37381](https://github.com/microsoft/vcpkg/pull/37381#discussion_r1543634645)

### INT-006: Make every exported path resolve in the installed tree

- **Rule:** Every file and directory referenced by installed configs and targets, including `IMPORTED_LOCATION_*`, `INTERFACE_INCLUDE_DIRECTORIES` (via `$<INSTALL_INTERFACE:include>`), custom `*_INCLUDE_DIR`/`*_LIB_DIR` variables, helper files and tool executables, must exist with matching case after `vcpkg_cmake_config_fixup`. When the portfile relocates or deletes binaries, fix the exports (`TOOLS_PATH`, patches, or not exporting them). One dangling reference breaks `find_package` for every consumer.
- **Check:** Consumer errors "references the file ... but this file does not exist" or "non-existent path ... in its INTERFACE_INCLUDE_DIRECTORIES"; targets for tools moved to `tools/<port>` or libraries deleted for one linkage; `share/<pkg>/../../` paths meant to reach `lib/`; dangling symlinks in `tools/`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: CMake](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-cmake); [vcpkg_cmake_config_fixup](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_cmake_config_fixup); PRs: [#46145](https://github.com/microsoft/vcpkg/pull/46145#issuecomment-3138228690), [#50240](https://github.com/microsoft/vcpkg/pull/50240#pullrequestreview-3878626187)

### INT-007: Resolve debug and release libraries per configuration

- **Rule:** Exported targets, wrappers and Find modules must give Debug consumers the `debug/lib` binaries and Release consumers the `lib` binaries, via `IMPORTED_LOCATION_<CONFIG>` or separate `find_library` results merged with `select_library_configurations`, and must work with multi-config generators. Never collapse both configurations into one name, path or variable; leave RelWithDebInfo and MinSizeRel to the mappings `vcpkg.cmake` already sets. Mixed configurations cause link and runtime failures.
- **Check:** Look for `*Targets-debug.cmake` locations outside `debug/lib`, a single `IMPORTED_LOCATION` or `find_library` result, variables mixing debug and release libraries, and cmake-user "Release lib for 'Debug' build" errors; build a Debug consumer with Ninja Multi-Config or Visual Studio.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#53185](https://github.com/microsoft/vcpkg/pull/53185#pullrequestreview-4849444838), [#38107](https://github.com/microsoft/vcpkg/pull/38107#issuecomment-2142845649)

### INT-008: Export every public target with its own usage requirements

- **Rule:** Put every consumer-facing library, and every target it links, into the package's namespaced export set so one `find_package` provides all documented targets, and keep internal helpers unexported. Each target must carry its own include directories, definitions and dependencies, so users never link helper targets such as `*_compiler_flags`; fix missing requirements in the providing port instead of patching each consumer.
- **Check:** Consume each documented target alone from a test project; look for "requires target ... that is not in any export set", installed headers without a linkable target, per-library side configs, helper or underscore targets in usage, and consumer patches adding a dependency's defines.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist: c000010](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000010); PRs: [#53615](https://github.com/microsoft/vcpkg/pull/53615#pullrequestreview-5063316141), [#53929](https://github.com/microsoft/vcpkg/pull/53929#pullrequestreview-5555582918)

### INT-009: Link through imported targets, not raw names or paths

- **Rule:** Builds, patches and exported link interfaces must use dependencies' imported targets (e.g., `OpenSSL::SSL`, `ZLIB::ZLIB`) instead of bare library names, `link_directories`, absolute paths or hand-written debug/optimized name lists that miss vcpkg's debug and static names. Export namespaced targets (`Pkg::target`) and keep un-exported ad-hoc IMPORTED targets out of link interfaces, so CMake reports a missing package at configure time instead of the linker picking a wrong binary.
- **Check:** Plain names (`z`, `zlibd`, `uv`) or `${VCPKG_IMPORT_PREFIX}/lib/*.a` paths in exported `INTERFACE_LINK_LIBRARIES`; `install(EXPORT)` without `NAMESPACE`; configs that define no targets; patches adding `link_directories()` or un-namespaced `target_link_libraries` entries.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#53673](https://github.com/microsoft/vcpkg/pull/53673#pullrequestreview-5063075558), [#41649](https://github.com/microsoft/vcpkg/pull/41649#discussion_r1807417821)

### INT-010: Bake the installed linkage into public headers

- **Rule:** Installed headers must declare symbols correctly for the installed linkage without consumer-defined macros: static builds must not default to `__declspec(dllimport)`, and DLL builds must give consumers dllimport. Hard-code the triplet's choice (e.g., `FOO_STATIC`, `FOO_DLL`) with a patch or `vcpkg_replace_string` instead of relying only on `INTERFACE_COMPILE_DEFINITIONS` or .pc Cflags, and prefer this over restricting linkage. MSBuild and direct consumers receive no exported flags.
- **Check:** Link a direct consumer using only `<triplet>/include` and the installed .lib files, with no extra `-D` flags, on x64-windows and x64-windows-static in Release and Debug; look for unresolved `__imp_` symbols and linkage macros defined only in exported metadata.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg PR review guide](https://github.com/microsoft/vcpkg/blob/master/.github/skills/shared/review-vcpkg-pr-guide.md); PRs: [#53719](https://github.com/microsoft/vcpkg/pull/53719#issuecomment-5640914645), [#39090](https://github.com/microsoft/vcpkg/pull/39090#discussion_r1631028763)

### INT-011: Bake build configuration and feature choices into headers

- **Rule:** Macros that select features, backends, polyfills or ABI-affecting options (e.g., `ASIO_STANDALONE`, index widths, external-library switches) must be recorded in the installed headers, typically a generated config header with library-prefixed names, so consumers get the build's configuration without extra defines. Headers must not auto-enable integrations outside the selected features (e.g., via `__has_include`), and auto-link pragmas must name installed libraries.
- **Check:** Compile a consumer with only the installed `include/` and no `-D` flags; grep public headers for `#ifdef` or `__has_include` on build-time choices, definitions provided only through `INTERFACE_COMPILE_DEFINITIONS`, and `#pragma comment(lib, ...)` names missing from `lib/`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Bake polyfill replacements into the installed tree](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#a-feature-may-replace-polyfills-with-aliases-provided-that-replacement-is-baked-into-the-installed-tree); [Maintainer guide: No feature-controlled alternatives in published interfaces](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-use-features-to-control-alternatives-in-published-interfaces); PRs: [#25115](https://github.com/microsoft/vcpkg/pull/25115#discussion_r892708986), [#43506](https://github.com/microsoft/vcpkg/pull/43506#issuecomment-3423299432)

### INT-012: Install complete, relocatable pkg-config files via vcpkg_fixup_pkgconfig

- **Rule:** Install .pc files in `lib/pkgconfig` and `debug/lib/pkgconfig` (`share/pkgconfig` only if configuration-independent), keeping upstream's default PKGDIR, and call `vcpkg_fixup_pkgconfig`. Each must define prefix, libdir, includedir and Version with `${prefix}`-relative paths, and Cflags must match the real header layout (no empty `-I` or `debug/include`); patch the generator the build actually uses. Broken paths strand non-CMake consumers; cosmetic fields like Name may be follow-ups.
- **Check:** Run `pkgconf --cflags --libs` on `lib/pkgconfig` and `debug/lib/pkgconfig`; look for empty `includedir=`, `libdir=` or `Version:`, non-`${prefix}` absolute paths, missing `vcpkg_fixup_pkgconfig()`, unsubstituted .pc.in variables, and patched templates the build ignores (e.g., Meson's `pkgconfig.generate()`).
- **Severity:** blocking · **Scope:** all
- **Sources:** [Installation tree layout: pkgconfig](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-pkgconfig); [vcpkg_fixup_pkgconfig](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_fixup_pkgconfig); PRs: [#24587](https://github.com/microsoft/vcpkg/pull/24587#discussion_r868750941), [#53849](https://github.com/microsoft/vcpkg/pull/53849#pullrequestreview-5160619513)

### INT-013: Reference vcpkg dependencies as resolvable Requires modules

- **Rule:** In .pc files, name other vcpkg packages as modules in `Requires` or `Requires.private` (e.g., openssl, bzip2) instead of hardcoding their `-l` flags; `Libs.private` is for system libraries. Every listed module must come from a declared (feature) dependency on that triplet: fix the entry, add the dependency or missing .pc, or drop an unusable .pc rather than using `SKIP_CHECK`. Module references carry each dependency's own transitive flags.
- **Check:** `Libs` or `Libs.private` with `-lssl -lcrypto`, `-lz` or `-lbz2` for vcpkg ports; `vcpkg_fixup_pkgconfig` "--exists <module> failed" or "Package X ... not found" errors; misspelled fields such as `Requires-private`; `Requires` entries without a matching vcpkg.json dependency.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_fixup_pkgconfig: SKIP_CHECK](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_fixup_pkgconfig#skip_check); PRs: [#54536](https://github.com/microsoft/vcpkg/pull/54536#pullrequestreview-5606795789), [#49113](https://github.com/microsoft/vcpkg/pull/49113#issuecomment-3707156223)

### INT-014: Keep published version metadata equal to the packaged release

- **Rule:** Version metadata the package publishes (upstream `<Pkg>ConfigVersion.cmake`, .pc `Version`, version macros) must be well-formed and equal the packaged release so versioned and versionless `find_package` calls succeed; pass `${VERSION}` instead of hardcoding it in patches. Avoid adding version files to vcpkg-authored configs or version pins to `find_dependency`; the review guide allows but strongly discourages publishing or constraining versions. When an update leaves dependents' requested compatibility range, patch their requests.
- **Check:** Compare `PACKAGE_VERSION` in `share/<pkg>/*ConfigVersion.cmake` and .pc `Version:` with vcpkg.json; test `find_package(<pkg> <version> CONFIG REQUIRED)` and a versionless call; look for git-describe or stale hardcoded versions and dependents' `find_package(<pkg> X.Y)` requests.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg PR review guide](https://github.com/microsoft/vcpkg/blob/master/.github/skills/shared/review-vcpkg-pr-guide.md); PRs: [#54249](https://github.com/microsoft/vcpkg/pull/54249#pullrequestreview-5399421092), [#54174](https://github.com/microsoft/vcpkg/pull/54174#discussion_r4141404522)

### INT-015: Keep upstream CMake package and target names

- **Rule:** Expose upstream's CMake package names, namespaces and target names exactly: don't rename them through patches, `EXPORT_NAME` or `file(RENAME)`, and don't drop targets or CMake functions upstream documents. Fix only genuinely broken upstream exports, reporting them upstream, and provide old or alternative names through INTERFACE or ALIAS compatibility targets. Upstream names are the interface users share with every other package source.
- **Check:** Patches changing `add_library` names, `EXPORT_NAME`, `install(EXPORT ... NAMESPACE|FILE)` or config file names without a stated conflict; exported target names changing case or suffix between versions; removed upstream-documented targets or functions.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not rename binaries](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-rename-binaries-outside-the-names-given-by-upstream); PRs: [#50214](https://github.com/microsoft/vcpkg/pull/50214#issuecomment-3985950085), [#29952](https://github.com/microsoft/vcpkg/pull/29952#issuecomment-1453115783)

### INT-016: Don't silently break existing consumers in port updates

- **Rule:** When an update changes installed package or target names, library names, Find modules, wrappers or pkg-config files, keep the old interface working for a transition, e.g., a forwarding config that `find_dependency`s the new package, adds aliases and prints a deprecation warning, or explicitly agree on the break and document the replacement in usage. Don't remove working integration "just because"; existing user projects depend on it.
- **Check:** Diff installed `share/*/` configs, exported targets, .pc files and lib/bin names between old and new versions; look for removed `unofficial-<port>` configs, `vcpkg-cmake-wrapper.cmake` or `Find*.cmake` files without a shim, and dependents patched only to follow renamed targets.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** PRs: [#55168](https://github.com/microsoft/vcpkg/pull/55168#pullrequestreview-5987191538), [#31551](https://github.com/microsoft/vcpkg/pull/31551#discussion_r1199960274)

### INT-017: Install only CMake modules and names the port owns

- **Rule:** Don't install Find modules for dependencies or other projects, configs or wrappers under names other projects own, or targets that collide with another port's or mimic a dependency's (e.g., `ZSTD::zstd`), and don't append to `CMAKE_MODULE_PATH` from installed configs. Fix the dependency's own config instead; moving files to another `share/` directory doesn't disambiguate. Stray modules shadow CMake's and break consumers' own lookups.
- **Check:** `share/<port>/Find*.cmake` for other packages or upstream modules consumers can never use; `list(APPEND CMAKE_MODULE_PATH ...)` in installed configs; exported package or target names already used by existing ports; `if(NOT TARGET X)` blocks creating dependency-named targets.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); PRs: [#38265](https://github.com/microsoft/vcpkg/pull/38265#issuecomment-2166880796), [#50214](https://github.com/microsoft/vcpkg/pull/50214#pullrequestreview-4942033904)

### INT-018: Generate configs from the build's export with a targets file

- **Rule:** When a port or patch adds a config, generate it from the build: `install(EXPORT)` to `<pkg>-targets.cmake` plus a `configure_package_config_file` config with `@PACKAGE_INIT@`, rather than a Find module plus wrapper or hand-coded paths. The config finds dependencies and then includes the targets file; never install a raw export file as the config when dependencies exist, and populate every placeholder. Exported configs get per-configuration properties for free.
- **Check:** `<pkg>-config.cmake` that defines IMPORTED targets directly; `check_required_components` without `@PACKAGE_INIT@` ("Unknown CMake command"); empty `set_and_check` or `@PACKAGE_...@` values; port-supplied `Find*.cmake` plus wrapper where the build knows its outputs.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#24078](https://github.com/microsoft/vcpkg/pull/24078#issuecomment-1096162197), [#46137](https://github.com/microsoft/vcpkg/pull/46137#issuecomment-3190059243)

### INT-019: Keep installed configs and wrappers robust for any consumer

- **Rule:** Installed configs and wrappers must survive repeated, nested, QUIET, versioned and component `find_package` calls: guard imported-target creation with `if(NOT TARGET)`, don't mutate existing imported targets, never `message(FATAL_ERROR)` in wrappers, and provide requested components or fail at configure time. Bake port-time decisions in with `configure_file(@ONLY)`, and use only features of the oldest CMake vcpkg supports for consumer projects. Non-REQUIRED lookups must be able to fail gracefully.
- **Check:** `add_library(... IMPORTED)` without TARGET guards, FATAL_ERROR or unguarded target use in wrappers, unsubstituted `@VAR@`; test a second and a QUIET `find_package`, and build `scripts/test_ports/cmake-user` with its `cmake-3-16` feature to catch newer CMake features such as ALIAS of non-global IMPORTED targets.
- **Severity:** blocking · **Scope:** all
- **Sources:** [CMake guidelines: CMake versions to require](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#cmake-versions-to-require); PRs: [#36303](https://github.com/microsoft/vcpkg/pull/36303#discussion_r1470695198), [#54705](https://github.com/microsoft/vcpkg/pull/54705#discussion_r4418558383)

### INT-020: Keep consumer-affecting flags out of exported metadata

- **Rule:** Installed binaries and exported metadata (CMake targets, .pc files, `*-config` scripts, qmake `.pri` files) must not impose the producing build's settings on consumers: no `-O3`, `-march=native`, `-flto`, `-fno-rtti`, sanitizer, warning, `-Werror`, or `/utf-8` options in `INTERFACE_COMPILE_OPTIONS`/`INTERFACE_LINK_OPTIONS`, no `-std=` or `/std:` in .pc Cflags, and no sanitizer instrumentation needing unshipped runtimes. The triplet and consumer choose these; fix the root cause instead of exporting workaround flags.
- **Check:** Grep `share/<port>/*Targets*.cmake`, `lib/pkgconfig/*.pc`, and `*-config` scripts for `-march`, `-O[0-3]`, `-flto`, `-fsanitize`, `-fno-rtti`, `-Werror`, `/utf-8`, and `-std=`; upstream `*_ENABLE_ASAN` or `*_ENABLE_WARNINGS` options defaulting ON; patches adding PUBLIC or INTERFACE compile options.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg PR review guide](https://github.com/microsoft/vcpkg/blob/master/.github/skills/shared/review-vcpkg-pr-guide.md); PRs: [#42358](https://github.com/microsoft/vcpkg/pull/42358#issuecomment-2513165102), [#52203](https://github.com/microsoft/vcpkg/pull/52203#pullrequestreview-4440501517)

### INT-021: Don't download, generate or require undeclared packages in configs

- **Rule:** Installed configs and port-config scripts may only `find_dependency` packages vcpkg installed: patch out FetchContent, ExternalProject or `file(DOWNLOAD)` fallbacks, generate headers during the port build instead of via `execute_process` at `find_package` time, and require no undeclared packages or tools such as Python3. Locate port-provided tools with `find_program(... REQUIRED)` under the host triplet's `tools/<port>`. Consume-time work escapes binary caching and fails late.
- **Check:** Grep installed `share/<port>/*.cmake` and `vcpkg-port-config.cmake` for FetchContent, ExternalProject, `file(DOWNLOAD)`, `execute_process`, "Fetching" messages, `find_package` of undeclared packages, and `find_program` calls lacking vcpkg tools paths or using bare `EXISTS` checks.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#52474](https://github.com/microsoft/vcpkg/pull/52474#discussion_r3456902342), [#47310](https://github.com/microsoft/vcpkg/pull/47310#pullrequestreview-3214704030)

### INT-022: Don't invent pkg-config files upstream doesn't provide

- **Rule:** Don't add vcpkg-authored .pc files or modules for libraries that upstream doesn't canonically expose through pkg-config; installing an upstream .pc.in shipped in the release sources is fine. If maintainers do accept a port-authored module, use the name major distributions ship (e.g., `mad.pc`), and leave project-specific needs to overlay ports or upstream. Non-native metadata becomes an unmaintained vcpkg-only interface.
- **Check:** New `*.pc.in`, `file(WRITE ... .pc)` or `configure_file(... .pc)` in the port directory or patches without an upstream counterpart; compare chosen module names with Debian and RHEL packages.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#35813](https://github.com/microsoft/vcpkg/pull/35813#issuecomment-1877857360), [#47427](https://github.com/microsoft/vcpkg/pull/47427#issuecomment-3330328288)

### INT-023: Carry static transitive link requirements in installed metadata

- **Rule:** For static linkage, consumers must link without adding libraries by hand: exported CMake targets must list every transitive library, including dependency sub-libraries and system libraries such as Ws2_32, bcrypt, libm or pthread under platform conditions, and .pc files must express them via `Requires.private` and `Libs.private`, with C++ libraries adding their C++ runtime. Regressions that stop static consumers linking block merge; older gaps become follow-ups.
- **Check:** Link minimal static consumers (x64-windows-static, x64-linux) once only via `find_package` and once only via `pkg-config --static`, in Release and Debug; look for unresolved symbols and upstream .pc logic that sets private libraries only for shared builds.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_fixup_pkgconfig](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_fixup_pkgconfig); PRs: [#52902](https://github.com/microsoft/vcpkg/pull/52902#pullrequestreview-4699309526), [#28373](https://github.com/microsoft/vcpkg/pull/28373#pullrequestreview-1220362128)

### INT-024: Use wrappers only to complement official Find modules

- **Rule:** A `vcpkg-cmake-wrapper.cmake` may only add vcpkg particulars (debug names, static transitive dependencies, triplet linkage) to an official CMake Find module or config, and must ship from the port owning that package under the exact name it intercepts. Keep the module's documented variables and targets, add no vcpkg-only variables, and never invent an interface or make module and config modes disagree. Projects outside vcpkg rely on that contract.
- **Check:** For new or changed `share/<Pkg>/vcpkg-cmake-wrapper.cmake`, ask whether CMake ships `Find<Pkg>.cmake`, the port owns `<Pkg>`, and documented results such as `JPEG::JPEG` survive; flag `<Pkg>_LIBRARIES` redefined as targets, `*_USE_STATIC_LIBS` branches, or targets created from scratch. Patches only filling `TARGET_RUNTIME_DLLS` are disputed.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#35559](https://github.com/microsoft/vcpkg/pull/35559#issuecomment-1848389510), [#36111](https://github.com/microsoft/vcpkg/pull/36111#issuecomment-1888495007)

### INT-025: Make .pc library flags match the installed files

- **Rule:** Libs entries must name the libraries actually installed for each configuration and linkage, including debug postfixes, `-static` suffixes, and MSVC lib-prefixed or versioned names, and must not advertise Unix-only libraries (`-lm`) or GNU-only flags such as `-Wl,-rpath` for MSVC. List independent system libraries last, and fix entries with `vcpkg_replace_string` or patches rather than renaming binaries, avoiding broad replacements of short tokens. Mismatched names break MSVC, Meson and autotools consumers.
- **Check:** Compare `-l` names in `lib/pkgconfig` and `debug/lib/pkgconfig` with files in `lib/` and `debug/lib/`; run `pkg-config --libs [--static]` for Release and Debug consumers and look for LNK1181 or "cannot find -l" errors.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Installation tree layout: pkgconfig](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout#layout-pkgconfig); PRs: [#54959](https://github.com/microsoft/vcpkg/pull/54959#pullrequestreview-5835227960), [#51725](https://github.com/microsoft/vcpkg/pull/51725#issuecomment-4443459137)

### INT-026: Install and fix upstream's integration files

- **Rule:** When upstream provides CMake config or pkg-config files, install them on every platform, patching install rules if they are generated but not installed, and repair defects with fixups or minimal patches instead of deleting or replacing them. Missing integration is not a defect, so port-authored configs are optional; once upstream ships an official export, switch to it and update dependents. Users expect upstream's bindings, which upstream maintains.
- **Check:** `file(REMOVE)` of `*.pc` or `*Config.cmake` in the portfile; port-supplied configs where upstream ships its own; upstream `install(EXPORT)` or .pc.in with nothing installed; triplets lacking `share/<pkg>` configs; unofficial exports kept after upstream adopted an official one.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [PR review checklist: c000010](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000010); [vcpkg PR review guide](https://github.com/microsoft/vcpkg/blob/master/.github/skills/shared/review-vcpkg-pr-guide.md); PRs: [#26188](https://github.com/microsoft/vcpkg/pull/26188#issuecomment-1212330371), [#31150](https://github.com/microsoft/vcpkg/pull/31150#issuecomment-1631231745)

### INT-027: Keep pkg-config out of CMake lookups and exported configs

- **Rule:** CMake builds and exported configs should use dependencies' CMake configs or official Find modules rather than `pkg_check_modules`, and patches shouldn't switch working CMake lookups to pkg-config. Exported targets must not need pkg-config at consume time (no `PkgConfig::` targets or `find_dependency(PkgConfig)`); if the build needs pkg-config, link `<PREFIX>_LINK_LIBRARIES` so nothing leaks into the export. MSVC users usually lack pkg-config, and it ignores multi-config generators.
- **Check:** Grep patches and installed `share/**/*.cmake` for `find_package(PkgConfig)`, `pkg_check_modules`, `pkg_search_module` and `PkgConfig::`, especially for dependencies that ship CMake configs.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#52891](https://github.com/microsoft/vcpkg/pull/52891#discussion_r3825428562), [#49070](https://github.com/microsoft/vcpkg/pull/49070#discussion_r2660412800)

### INT-028: Use one linkage-independent target and module name

- **Rule:** Consumers should use the same CMake package, target and pkg-config module names on static and dynamic triplets, letting the triplet choose linkage instead of separate `*_static`/`*_shared` targets or components. When upstream names differ by linkage, add an INTERFACE target or alias that selects the installed variant, or cover both in usage; upstream `_static` file suffixes themselves are legitimate. Uniform names keep consumer code triplet-independent.
- **Check:** Exported target or .pc names containing static/shared; usage differing between x64-windows and x64-windows-static; dependents patched with `$<IF:$<TARGET_EXISTS:...>>`; configs unconditionally creating aliases for both variants.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Do not rename binaries](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#do-not-rename-binaries-outside-the-names-given-by-upstream); [Maintainer guide: Only static or shared](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#only-static-or-shared); PRs: [#48996](https://github.com/microsoft/vcpkg/pull/48996#issuecomment-3678013971), [#25004](https://github.com/microsoft/vcpkg/pull/25004#pullrequestreview-992589377)

### INT-029: Write hand-written configs and Find modules portably

- **Rule:** Hand-written configs, wrappers and Find modules must search only vcpkg's `lib` and `debug/lib` with `NO_DEFAULT_PATH`, call `find_library` without `REQUIRED` and check the result, and avoid platform-specific file names, using `CMAKE_STATIC_LIBRARY_PREFIX`/`SUFFIX` or `NAMES_PER_DIR` and plain system names like `ws2_32` rather than `ws2_32.lib`. Create UNKNOWN imported targets with per-configuration locations, not INTERFACE ones. Hardcoded names break other platforms such as MinGW.
- **Check:** Literal `lib*.a` or `*.lib` names, removed `NO_DEFAULT_PATH`, or PATHS turned into HINTS in `ports/<port>/*.cmake(.in)` and patches; INTERFACE IMPORTED targets carrying library paths; `find_library(... REQUIRED)` inside configs.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#51234](https://github.com/microsoft/vcpkg/pull/51234#discussion_r3114241772), [#31453](https://github.com/microsoft/vcpkg/pull/31453#discussion_r1194757991)

### INT-030: Find dependencies with standard find_package in the right mode

- **Rule:** Look up dependencies with plain `find_package`: module mode for packages CMake provides Find modules for (e.g., OpenMP, ZLIB) and CONFIG only for packages that ship configs; moving a working CONFIG lookup to modules is suspicious. Don't patch lookups that already work under vcpkg, write custom `find_library` code, add Find modules for dependencies that install configs, or rely on bundled third-party Find modules that guess the dependency's configuration.
- **Check:** `find_package(OpenMP CONFIG)` or other forced CONFIG for module-only packages; custom `find_path`/`find_library` blocks replacing `find_package`; new or project-bundled `Find*.cmake` for config-providing dependencies; one package resolved through both module and config.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#52429](https://github.com/microsoft/vcpkg/pull/52429#issuecomment-4736316036), [#45677](https://github.com/microsoft/vcpkg/pull/45677#discussion_r2122716714)

### INT-031: Explain how consumers build exported C++ modules

- **Rule:** For ports exporting C++20 modules that every consumer compiles (e.g., an `EXCLUDE_FROM_ALL` module library target), the contributor should explain how dependent ports and diamond dependencies consume them, including whether each consumer builds its own copy and how duplicates are resolved. Maintainers want that downstream story confirmed before accepting the design.
- **Check:** Installed module interface units or module targets compiled inside consumers; ask what happens when two libraries in one dependency graph both import the module.
- **Severity:** advisory · **Scope:** new-port
- **Sources:** PRs: [#45995](https://github.com/microsoft/vcpkg/pull/45995#issuecomment-2989281064)

### INT-032: Match the exact case of installed config paths and module names

- **Rule:** `CONFIG_PATH` and `PACKAGE_NAME` arguments to `vcpkg_cmake_config_fixup`, configs' file names, and pkg-config module names must match the exact case upstream installs (for example `share/cmake/LightningScanner`, not `share/cmake/${PORT}`). Windows' case-insensitive filesystem hides mismatches that then fail on Linux and macOS.
- **Check:** Compare `CONFIG_PATH` values (especially ones built from `${PORT}`) and module names with the installed file list; errors such as "'.../debug/share/cmake/<name>' does not exist" or "Required package X is not available" on case-sensitive hosts only.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#31631](https://github.com/microsoft/vcpkg/pull/31631#discussion_r1208940091), [#31607](https://github.com/microsoft/vcpkg/pull/31607#issuecomment-1565376051)

### INT-033: Export Windows DLLs as SHARED IMPORTED targets with import libraries

- **Rule:** Hand-written or patched CMake targets for Windows DLLs must be `SHARED IMPORTED` with `IMPORTED_IMPLIB` set to the import library and `IMPORTED_LOCATION` set to the DLL. An `UNKNOWN` target whose location is the DLL makes consumers pass the DLL to the linker.
- **Check:** `add_library(... UNKNOWN IMPORTED)` or `IMPORTED_LOCATION` pointing at `bin/*.dll` without `IMPORTED_IMPLIB`; consumer `LNK1107: invalid or corrupt file` errors.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#52689](https://github.com/microsoft/vcpkg/pull/52689#pullrequestreview-4622003238)

### INT-034: Give independently released components their own CMake packages

- **Rule:** When related upstream components are packaged as separate ports with independent repositories and release cycles, each port ships its own CMake package instead of one config spanning several ports or reaching into another port's internals. Tightly coupled components can instead be features of one port.
- **Check:** New ports from the same upstream family that share one config or targets file, or configs that include files owned by another port.
- **Severity:** non-blocking · **Scope:** new-port
- **Sources:** PRs: [#54705](https://github.com/microsoft/vcpkg/pull/54705#discussion_r4499297698)

## USE: Usage text

### USE-001: Verify usage by building a consumer from it verbatim

- **Rule:** The usage vcpkg prints, custom or generated, must work unchanged: a minimal consumer using exactly those lines and including a main public header must configure, compile, and link in Release and Debug on dynamic and static triplets. The usage must include a `find_package` for every target it references, and the consumer must need no extra definitions (e.g., `NOMINMAX`) or include paths, because users copy usage verbatim.
- **Check:** Paste `vcpkg print-usage <port>:<triplet>` output into a CMake project using the vcpkg toolchain on x64-windows, x64-windows-static, and x64-linux; flag "target was not found", "Could not find a package configuration file", C1083, or LNK1104 errors.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Usage documentation: Overview](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#overview); PRs: [#35412](https://github.com/microsoft/vcpkg/pull/35412#issuecomment-1833242760), [#44263](https://github.com/microsoft/vcpkg/pull/44263#issuecomment-2709640841)

### USE-002: Name only installed, public packages, targets, and paths

- **Rule:** Every `find_package` name (with matching case), target, pkg-config module, variable, and path in usage must exist in what the port installs for the enabled features on every supported triplet, and only public targets may appear, not internal helpers such as `*_compiler_flags`. Don't invent targets that no config provides or copy lines from another port's usage, and update usage when the layout changes, since stale names break every consumer.
- **Check:** Compare each usage line with `share/<pkg>/*Config.cmake`, `*Targets.cmake`, installed `.pc` files, and documented paths; flag internal, missing, misspelled, or other ports' names.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Usage documentation: Supplying a usage file](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#supplying-a-usage-file); PRs: [#45436](https://github.com/microsoft/vcpkg/pull/45436#discussion_r2132641167), [#54872](https://github.com/microsoft/vcpkg/pull/54872#discussion_r4499386914)

### USE-003: Make usage hold for every linkage, platform, and feature

- **Rule:** Usage must hold for every supported linkage, platform, and feature: when generated usage differs by linkage or advertises feature-, plugin-, or linkage-dependent targets, supply a usage file with one uniform instruction (e.g., `$<IF:$<TARGET_EXISTS:a>,a,b>`) naming only targets users link directly. Annotate what a feature provides, avoid aggregate targets whose contents vary with features, and mention mandatory steps such as required exports or behavior-changing triplet variables.
- **Check:** Compare print-usage output and `add_library(... IMPORTED)` names across x64-windows, x64-windows-static, and Linux or macOS; inspect `INTERFACE_LINK_LIBRARIES`, feature-gated targets, and whether advice such as adding `tools/` to PATH also holds for Debug.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Usage documentation: Supplying a usage file](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#supplying-a-usage-file); PRs: [#40673](https://github.com/microsoft/vcpkg/pull/40673#issuecomment-2318331446), [#52971](https://github.com/microsoft/vcpkg/pull/52971#pullrequestreview-4732724594)

### USE-004: Install the usage file to share/${PORT}/usage

- **Rule:** A `usage` file in the port directory must be installed, normally with `file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")`; feature-specific notes may be appended to the installed copy in the portfile. Don't silence the post-build check with `VCPKG_POLICY_SKIP_USAGE_INSTALL_CHECK`: an uninstalled usage file fails the CI build and never reaches users.
- **Check:** The post-build message "this port contains a file named "usage" but didn't install it", or `VCPKG_POLICY_SKIP_USAGE_INSTALL_CHECK` in portfile.cmake.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Usage documentation: Supplying a usage file](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#supplying-a-usage-file); [Policies: VCPKG_POLICY_SKIP_USAGE_INSTALL_CHECK](https://learn.microsoft.com/vcpkg/reference/policies#vcpkg_policy_skip_usage_install_check); PRs: [#45923](https://github.com/microsoft/vcpkg/pull/45923#pullrequestreview-2918615325), [#51353](https://github.com/microsoft/vcpkg/pull/51353#discussion_r3134073630)

### USE-005: Add a usage file only when generated usage is wrong

- **Rule:** Supply `ports/<port>/usage` only when `vcpkg print-usage --generated` is incorrect or incomplete; delete files substantially identical to the generated text (differing only in indentation or the heuristic disclaimer) along with their install line, because redundant copies drift. When generated usage is correct, optionally install an empty `share/${PORT}/usage-accurate` marker, which drops the heuristic warning, instead of copying the text.
- **Check:** Install the port and compare `vcpkg print-usage <port>:<triplet>` with `vcpkg print-usage --generated <port>:<triplet>`; for new ports, ask the contributor to confirm the generated text is accurate.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Usage documentation: Overview](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#overview); [Usage documentation: Affirming generated usage](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#affirming-generated-usage); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#53527](https://github.com/microsoft/vcpkg/pull/53527#discussion_r3884053488), [#54372](https://github.com/microsoft/vcpkg/pull/54372#discussion_r4233671631)

### USE-006: Keep usage a short synopsis of official imported targets

- **Rule:** Usage shows the minimum integration with the imported targets upstream recommends, preferring implementation-agnostic ones such as `JPEG::JPEG`, listing separately consumable APIs separately and other targets in comments. Omit banners, URLs, install commands, linkage or triplet explanations, tool instructions such as `x-add-path`, upstream FetchContent or add_subdirectory blocks, legacy variables, bare `#include` advice, `${VCPKG_*}` paths, and patterns that only work through vcpkg wrappers; longer guidance belongs in the manifest's `documentation` field.
- **Check:** Usage with many targets or lines, URLs or ASCII art, `vcpkg install` lines, `include_directories(${X_INCLUDE_DIRS})`, or sub-port notes in a meta-port such as boost; a long target list can signal a packaging problem.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Usage documentation: Content format](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#content-format); PRs: [#38704](https://github.com/microsoft/vcpkg/pull/38704#discussion_r1597885398), [#36195](https://github.com/microsoft/vcpkg/pull/36195#discussion_r1456387357)

### USE-007: Follow the standard usage templates and formatting

- **Rule:** Start custom usage with `<port> provides CMake targets:` (port name, not package name) or `<port> is header-only and can be used from CMake via:`, then a blank line and two-space-indented snippets such as `find_package(<Pkg> CONFIG REQUIRED)` and `target_link_libraries(main PRIVATE <targets>)`; header-only usage pairs `find_path` with `target_include_directories`. Omit the heuristic disclaimer, end with a newline, and reformat touched usage files for consistency with generated output.
- **Check:** The first line, tab or four-space indentation, a consumer target other than `main`, "heuristically generated" text in a custom file, or `\ No newline at end of file`.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Usage documentation: Content format](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files#content-format); PRs: [#41150](https://github.com/microsoft/vcpkg/pull/41150#discussion_r1777649666), [#53133](https://github.com/microsoft/vcpkg/pull/53133#discussion_r3693634000)

### USE-008: Describe non-CMake packages with pkg-config modules or find_library

- **Rule:** For packages consumed through pkg-config, usage names the pkg-config modules, as generated usage does, rather than `find_package(PkgConfig)` or `pkg_check_modules` snippets, which misbehave on Windows; the 2022–2023 practice of requesting such snippets is superseded. Packages with neither CMake config nor pkg-config files still ship tested usage with `find_path` and one `find_library` per library, handling platform-specific names and debug/release; don't block it on adding CMake config.
- **Check:** Usage containing `pkg_check_modules` or `find_package(PkgConfig`, a package with no `share/<pkg>/*Config.cmake`, `.pc` file, or usage file, or a single `find_library` expected to find several libraries or both configurations.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#35813](https://github.com/microsoft/vcpkg/pull/35813#discussion_r1441172003), [#24584](https://github.com/microsoft/vcpkg/pull/24584#issuecomment-1121969958)

## LIC: License and copyright

### LIC-001: Make the license expression cover all installed content

- **Rule:** The `vcpkg.json` `"license"` SPDX expression must match upstream's grant (BSD-3-Clause text is not MIT) and cover everything installed or compiled in, such as vendored, derived, or downloaded third-party code, installed tools, and data-generated tables, combined with AND (e.g., `MIT AND BSL-1.0`), unless that part is removed or unvendored. Users rely on it for compliance; unbuilt sources and separately packaged dependencies, which declare their own licenses, don't count.
- **Check:** Compare `"license"` with upstream LICENSE, COPYING, and NOTICE files, per-file headers of installed headers and compiled sources, and vendored directories (`third_party/`, `extern/`, `contrib/`); flag, e.g., an MIT-only declaration when installed files carry BSD, BSL-1.0, Zlib, or Apache-2.0 terms.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json: license](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#license); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#52310](https://github.com/microsoft/vcpkg/pull/52310#pullrequestreview-4472695426), [#54076](https://github.com/microsoft/vcpkg/pull/54076#pullrequestreview-5313704141)

### LIC-002: Put every applicable license text and notice in copyright

- **Rule:** `share/${PORT}/copyright` must aggregate every license text and attribution notice that applies to installed content, because redistribution requires them: all upstream license files (e.g., COPYING plus COPYING.LESSER), Apache-2.0 NOTICE files, and licenses of vendored or derived code compiled into libraries or tools. Pass them all to one `vcpkg_install_copyright(FILE_LIST ...)` call instead of installing separate license files or folders, and re-check the list when updates rename or add license files.
- **Check:** Compare `FILE_LIST` with `LICENSE*`, `COPYING*`, and `NOTICE*` files in the source root and vendored directories; flag `share/<port>/` holding extra license files or LICENSES folders, and the error "vcpkg_install_copyright was passed a non-existing path".
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Install copyright file](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#install-copyright-file); [vcpkg_install_copyright](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_install_copyright); PRs: [#47014](https://github.com/microsoft/vcpkg/pull/47014#discussion_r2324410686), [#53220](https://github.com/microsoft/vcpkg/pull/53220#pullrequestreview-4870205048)

### LIC-003: Install upstream's own license text, unedited

- **Rule:** Build copyright from the packaged source's own license files, unedited, since vcpkg isn't the licensor: no forwarding stubs ("see LICENCE"), lists of file names, regex-extracted excerpts, hand transcriptions, or text the source doesn't authorize (e.g., from the project a fork derives from). For notices that exist only in headers, pass one representative header to `vcpkg_install_copyright`; for non-text licenses such as a PDF, write a dated note linking the upstream document.
- **Check:** Read the installed copyright; flag `string(REGEX)` or `file(STRINGS)` extraction, `file(WRITE)` license text without an `as of <date>, see <URL>` pointer, and license or `copyright` files committed under `ports/<port>/` although the source or a pinned upstream download provides them.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Install copyright file](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#install-copyright-file); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#24781](https://github.com/microsoft/vcpkg/pull/24781#issuecomment-1132066338), [#54564](https://github.com/microsoft/vcpkg/pull/54564#pullrequestreview-5621102638)

### LIC-004: Install the copyright file, preferably via vcpkg_install_copyright

- **Rule:** Every port must install its license as `share/${PORT}/copyright`, or post-build validation fails. New code should use `vcpkg_install_copyright(FILE_LIST ...)`; the older `file(INSTALL ... RENAME copyright)` remains allowed and shouldn't block unrelated updates.
- **Check:** Portfiles that produce no `share/${PORT}/copyright`; post-build copyright errors. Suggest `vcpkg_install_copyright` to new ports still using `file(INSTALL ... RENAME copyright)`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [Maintainer guide: Install copyright file](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#install-copyright-file); PRs: [#30742](https://github.com/microsoft/vcpkg/pull/30742#issuecomment-1509593715), [#25239](https://github.com/microsoft/vcpkg/pull/25239#issuecomment-1171623665)

### LIC-005: Use a null license when no SPDX expression fits

- **Rule:** Set `"license": null`, explaining the situation in the copyright file, when an SPDX expression would mislead: non-standard variants of known licenses (MIT with extra clauses), custom restrictions such as unRAR's, per-component licensing that AND would misstate (an LGPL library with GPL tools), or licensing that can't be identified confidently. Use AND only when all terms apply to the installed content, and never guess an identifier.
- **Check:** Compare license texts with SPDX templates; flag AND expressions assembled from whichever license files exist and identifiers guessed for non-standard text. Treat an existing null as intentional and inspect the copyright file instead.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json: license](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#license); PRs: [#32475](https://github.com/microsoft/vcpkg/pull/32475#discussion_r1427364454), [#32528](https://github.com/microsoft/vcpkg/pull/32528#pullrequestreview-1529038962)

### LIC-006: Ensure installed content may legally be redistributed

- **Rule:** Non-OSS or commercial licenses are acceptable only if they permit the redistribution vcpkg performs: verify that every installed artifact (e.g., PDBs, SDK files) is redistributable and ship those terms. Downloaded sources containing proprietary or unclear-redistribution material (even behind a disabled feature), upstream violations of a bundled component's license, or disputed provenance hold the port until upstream resolves them.
- **Check:** For prebuilt, NuGet, or SDK ports, compare installed files with the license's redistributable list; check that vendored components keep their required notices upstream; question sources named in DMCA or provenance disputes.
- **Severity:** blocking · **Scope:** new-port
- **Sources:** PRs: [#53127](https://github.com/microsoft/vcpkg/pull/53127#pullrequestreview-4824578623), [#51956](https://github.com/microsoft/vcpkg/pull/51956#discussion_r3344804586)

### LIC-007: Declare feature licenses for differently licensed feature content

- **Rule:** When a feature installs or compiles in content under terms the port's `"license"` doesn't cover, declare that feature's own `"license"` and add its notices to the copyright file when the feature is enabled, so metadata matches what users install. When upstream offers alternative licensings, follow its stated preference rather than adding license-switching features it doesn't want.
- **Check:** Features enabling GPL-only, proprietary, or otherwise differently licensed code without a feature `"license"` or matching copyright entries; features that only switch to a license variant upstream discourages.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json: feature license](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#feature-license); PRs: [#51956](https://github.com/microsoft/vcpkg/pull/51956#discussion_r3344804586), [#41618](https://github.com/microsoft/vcpkg/pull/41618#issuecomment-2632911890)

### LIC-008: Use current SPDX identifiers matching upstream's actual grant

- **Rule:** For GPL, LGPL, and AGPL, declare current SPDX identifiers (`GPL-2.0-only`, `LGPL-2.1-or-later`) instead of deprecated ones (`GPL-2.0`, `LGPL-2.1+`), choosing -only or -or-later from upstream's actual grant (source headers saying "or (at your option) any later version", the README, or a licensing FAQ), not from COPYING, which never says. If upstream is silent or contradictory, ask upstream and keep the deprecated identifier rather than guessing; the choice affects license compatibility.
- **Check:** Deprecated-license notices from the PR workflow (which `vcpkg format-manifest` doesn't catch); bare GPL/LGPL/AGPL version identifiers or `+` suffixes; grep installed headers and sources for "any later version" and compare with the declared variant.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#43863](https://github.com/microsoft/vcpkg/pull/43863#discussion_r1962720861), [#53324](https://github.com/microsoft/vcpkg/pull/53324#issuecomment-5247656916)

## PLT: Platform and triplet support

### PLT-001: Make every triplet that "supports" allows build

- **Rule:** Every official CI triplet allowed by the port's, or a tested feature's, `"supports"` must build, since `"supports"` tells users where the port works. For each failing triplet, fix the build or exclude that configuration; don't leave failures, add hacks such as disabling debug builds, or install an empty package where the build silently produced nothing. Errors such as x86-only intrinsics or SSE headers on ARM are real port bugs.
- **Check:** Per-triplet CI logs vs `"supports"`; failures on allowed triplets; "The folder /include is empty" or `VCPKG_POLICY_EMPTY_INCLUDE_FOLDER` on one platform; errors like "This header is specific to X86, X64 and ARM64EC targets" or C3861 on intrinsics.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist: c000006](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000006); [vcpkg.json: supports](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#supports); PRs: [#52495](https://github.com/microsoft/vcpkg/pull/52495#issuecomment-4775597580), [#48026](https://github.com/microsoft/vcpkg/pull/48026#issuecomment-3466293018)

### PLT-002: Narrow "supports" only with evidence of real incompatibility

- **Rule:** Exclude a configuration only with evidence (a build or configure error, or an upstream statement) that it can't work for anyone, not just in one environment, CI image, or toolchain setup; over-restriction hides working platforms from users and CI. Unknown platforms stay supported, so prefer known-bad exclusions to allowlists; prebuilt-binary ports list exactly the shipped platforms. Fix trivial breaks instead of excluding, and lift exclusions that a new version fixes.
- **Check:** `"supports"` narrowed without a linked log or upstream reference, citing dependencies vcpkg provides, or copied from upstream CI notes; previously working platforms dropped; allowlists like `linux | osx`; verify with `--allow-unsupported`. Copyleft ports that fail on Xbox may simply be marked `!xbox`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json: supports](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#supports); [PR review checklist: c000006](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000006); [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); PRs: [#52231](https://github.com/microsoft/vcpkg/pull/52231#issuecomment-4646368139), [#30333](https://github.com/microsoft/vcpkg/pull/30333#issuecomment-1481514121)

### PLT-003: Pair `ONLY_DYNAMIC_LIBRARY` with `!(static & staticcrt)`

- **Rule:** A port calling `vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)` adds `!(static & staticcrt)` to `"supports"`, with no ci.baseline entry, so users fail early. Don't widen it to `!static` (vcpkg_check_linkage safely switches static-library, dynamic-CRT triplets to dynamic) or `!staticcrt` (blocks explicit dynamic-library, static-CRT triplets); use `!staticcrt` only when the port truly forces the dynamic CRT, e.g., `ONLY_DYNAMIC_CRT` or prebuilt /MD binaries.
- **Check:** `ONLY_DYNAMIC_LIBRARY` or DLL-only prebuilt binaries vs `"supports"`; `<port>:x64-windows-static=fail` baseline entries; CI error "Refusing to build unexpected dynamic library against the static CRT"; the identifier is `staticcrt`, not `static-crt`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg_check_linkage: ONLY_DYNAMIC_LIBRARY](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_check_linkage#only_dynamic_library); PRs: [#42456](https://github.com/microsoft/vcpkg/pull/42456#discussion_r1868515585), [#37365](https://github.com/microsoft/vcpkg/pull/37365#discussion_r1523989646)

### PLT-004: Declare platform limits in "supports", not portfile failures

- **Rule:** Express unsupported platforms and feature/platform combinations in `vcpkg.json` `"supports"` (port or feature level), not with the deprecated `vcpkg_fail_port_install` or `message(FATAL_ERROR)` platform checks, so vcpkg rejects them before building dependencies. Only conditions that platform expressions can't express, such as minimum compiler versions or MSVC versus clang-cl, are checked at configure time with a clear error.
- **Check:** `vcpkg_fail_port_install(`, `if(VCPKG_TARGET_IS_...) message(FATAL_ERROR ...)`, or feature/platform FATAL_ERROR checks without a matching `"supports"`; requests to encode compiler versions in `"supports"`.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json: supports](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#supports); [vcpkg_fail_port_install](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_fail_port_install); [PR review checklist: c000001](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000001); PRs: [#29150](https://github.com/microsoft/vcpkg/pull/29150#issuecomment-1404157602), [#48059](https://github.com/microsoft/vcpkg/pull/48059#discussion_r2487691995)

### PLT-005: Verify "supports" logic excludes exactly the intended configurations

- **Rule:** Check the boolean logic of port and feature `"supports"` against the PR's stated intent: `windows & !arm64` drops every non-Windows platform whereas `!(windows & arm64)` drops only Windows ARM64, `arm` also matches arm64 (including arm64-osx), and `linux & !static` leaves no official CI triplet to test the port. A wrong expression silently removes platforms that used to work.
- **Check:** Evaluate old and new expressions for windows, linux, osx, android, uwp, arm64, static, and staticcrt; compare the result with the PR title and CI coverage.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg.json: supports](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#supports); PRs: [#28022](https://github.com/microsoft/vcpkg/pull/28022#discussion_r1034649722), [#23034](https://github.com/microsoft/vcpkg/pull/23034#discussion_r805106335)

### PLT-006: Reject Windows XP, OS-version knobs, and /clr toolchain changes

- **Rule:** Don't add ports, features, options, or patches that target Windows XP (or use proxies such as `mingw & x86` for it), invent target-OS-version settings, or change default Windows toolchain flags to mix native and /clr builds. These are explicit vcpkg non-goals; such needs belong in custom triplets, toolchains, or overlay ports.
- **Check:** `_WIN32_WINNT` values for XP, XP-named features or options, platform expressions used as OS-version proxies, and toolchain or triplet edits removing default flags for /clr.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#46863](https://github.com/microsoft/vcpkg/pull/46863#issuecomment-4299859408), [#40074](https://github.com/microsoft/vcpkg/pull/40074#issuecomment-2362323598)

### PLT-007: Put feature-specific platform limits on the feature

- **Rule:** When only a feature fails or needs something unavailable on some configurations, give that feature a `"supports"` derived from its own requirements, not copied from another feature, instead of restricting the port, and keep its dependencies unconditional so an explicit request on an unsupported platform fails clearly rather than being silently ignored. A feature documented as a no-op on some platforms must truly do nothing there.
- **Check:** Port-level `"supports"` or baseline entries for feature-only failures; features whose dependencies are all platform-qualified (e.g., alsa only on linux) but lack a feature `"supports"`; feature `"supports"` identical to another feature's.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg.json: feature supports](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#feature-supports); PRs: [#44722](https://github.com/microsoft/vcpkg/pull/44722#discussion_r2023531913), [#27740](https://github.com/microsoft/vcpkg/pull/27740#pullrequestreview-1179985843)

### PLT-008: Use vcpkg_check_linkage instead of "static" in "supports"

- **Rule:** Don't restrict a port with `"supports": "static"` because it only builds static libraries; call `vcpkg_check_linkage(ONLY_STATIC_LIBRARY)`, which builds a static library with a note on dynamic triplets. A `static` term changes nothing in the build and, combined with a host dependency on the port, effectively excludes Windows, whose host triplets are dynamic.
- **Check:** `"supports"` containing `static`, or allowlists of static configurations, for ports whose only limitation is linkage; hard-coded `add_library(... STATIC)` without `vcpkg_check_linkage`.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg_check_linkage: ONLY_STATIC_LIBRARY](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_check_linkage#only_static_library); PRs: [#23827](https://github.com/microsoft/vcpkg/pull/23827#discussion_r930409972), [#25899](https://github.com/microsoft/vcpkg/pull/25899#issuecomment-1192223285)

### PLT-009: Don't mirror dependencies' "supports" restrictions

- **Rule:** Restrict `"supports"` only for the port's own incompatibilities, not to copy a dependency's expression or upstream's marketing matrix. vcpkg already reports dependency cascades, and an install that fails only because a transitive dependency excludes a triplet isn't evidence that the port's `"supports"` is too broad, since an overlay or another version of that dependency may support it.
- **Check:** `"supports"` additions justified only by a dependency's limitation or identical to it (e.g., wangle copying folly's); review findings based solely on cascade failures.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [vcpkg.json: supports](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#supports); PRs: [#45176](https://github.com/microsoft/vcpkg/pull/45176#issuecomment-2829524095), [#28727](https://github.com/microsoft/vcpkg/pull/28727#issuecomment-1373399045)

### PLT-010: Avoid vcpkg-only enablement of niche toolchains and unwanted platforms

- **Rule:** Don't add piecemeal patches for toolchain variants (e.g., mingw-lite) or large platform-enablement patches upstream doesn't want (e.g., X11 libraries on Windows) unless upstream is interested or committed contributors maintain them, because vcpkg can't maintain that surface; title such PRs by their actual narrow scope. Small port-local workarounds that make a platform work are acceptable technical debt if they don't worsen other triplets.
- **Check:** Patches conditioned on unusual toolchains or platforms without upstream links; PR titles broader than the change (e.g., "fix MinGW"); whether platform workarounds alter behavior on existing triplets.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#54407](https://github.com/microsoft/vcpkg/pull/54407#issuecomment-6348148881), [#21584](https://github.com/microsoft/vcpkg/pull/21584#pullrequestreview-853465866)

### PLT-011: Treat multi-architecture builds as best-effort

- **Rule:** A list-valued `VCPKG_TARGET_ARCHITECTURE` (for example macOS universal binaries) isn't a first-class vcpkg feature. Don't require ports to support it, and don't add piecemeal universal-binary support to scripts or triplets without a long-term strategy and post-build checks that verify every claimed architecture is present.
- **Check:** Triplets, scripts, or portfiles that set several `VCPKG_OSX_ARCHITECTURES` or `CMAKE_OSX_ARCHITECTURES` values; review requests demanding multi-architecture support from ports with assembly or architecture-specific code.
- **Severity:** advisory · **Scope:** all
- **Sources:** PRs: [#25299](https://github.com/microsoft/vcpkg/pull/25299#pullrequestreview-1016009052), [#22978](https://github.com/microsoft/vcpkg/pull/22978#issuecomment-1310963495)

## CI: CI, baselines, and testing

### CI-001: Make CI pass on every triplet the port supports

- **Rule:** New and updated ports must build in CI on every triplet their `supports` allows, and failures are presumed legitimate. Contributors must read the "failure logs for <triplet>" artifacts (console output is insufficient), fix the root cause or restrict `supports` with evidence, and ask for help when stuck; broken PRs get drafted. Failures that also occur on master or with the baseline version, and infrastructure outages, aren't attributed to the PR.
- **Check:** Per-triplet Azure Pipelines results and failure-log artifacts (`*-out.log`); REGRESSION lines naming the PR's own port; compare with master or the baseline version before attributing a failure to the PR.
- **Severity:** blocking · **Scope:** all
- **Sources:** [PR review checklist: c000006](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist#c000006); PRs: [#46401](https://github.com/microsoft/vcpkg/pull/46401#issuecomment-3091348101), [#47918](https://github.com/microsoft/vcpkg/pull/47918#issuecomment-3434660280)

### CI-002: Fix regressions the change causes in dependent ports

- **Rule:** A change must not break reverse dependencies or vcpkg-ci test ports: REGRESSION and "cascaded, but it is required to pass" failures in other ports must be fixed in the same PR by patching or updating dependents, adjusting test ports, or constraining new dependencies by platform or feature, not baselined, because the registry ships one version of each port. Also check dependents for API breaks CI doesn't build, such as in non-default features.
- **Check:** CI "REGRESSION: <other-port>:<triplet>" lines and their logs; reverse dependencies found by grepping ports/*/vcpkg.json for the changed port or its targets; `vcpkg depend-info` or `--dry-run` installs with `--overlay-ports=scripts/test_ports` to find newly unsupported dependencies.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** [Maintainer guide: Make separate pull requests per port](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#make-separate-pull-requests-per-port); PRs: [#42678](https://github.com/microsoft/vcpkg/pull/42678#issuecomment-2902024580), [#51046](https://github.com/microsoft/vcpkg/pull/51046#issuecomment-4212471836)

### CI-003: Make every feature build alone, combined, and as core

- **Rule:** PR CI runs `vcpkg x-test-features` on modified ports (core alone, each feature alone, all combined), and users may request any combination, so every feature must build on the triplets it claims to support and compose with the others; for example, static all-feature builds must link. Fix failures, constrain genuinely unsupported features with feature-level `supports`, and build effectively mandatory parts unconditionally instead of as features. Reviewers also test `<port>[*]` locally.
- **Check:** CI "There are some feature test problems!" or "build failed but was expected to pass"; locally `vcpkg x-test-features <port>` or `vcpkg install <port>[*]:<triplet>` on x86-windows, x64-windows, x64-windows-static, and x64-linux.
- **Severity:** blocking · **Scope:** all
- **Sources:** [vcpkg x-test-features](https://learn.microsoft.com/vcpkg/commands/test-features); PRs: [#52937](https://github.com/microsoft/vcpkg/pull/52937#issuecomment-5060581015), [#53645](https://github.com/microsoft/vcpkg/pull/53645#issuecomment-5474209012)

### CI-004: Fix port failures instead of adding ci.baseline entries

- **Rule:** Failures caused by the port or the PR must be fixed, not recorded as `fail`/`skip` in scripts/ci.baseline.txt or hidden by disabled checks, and new ports shouldn't need entries beyond genuine lab limitations. A new entry needs a reproducible failure in a linked CI run (rerun sporadic ICEs or infrastructure hiccups), an understood cause, alphabetical placement, and a `# reason` comment, because it also stops PR CI from testing the port's dependents.
- **Check:** Added `<port>:<triplet>=fail|skip` lines for ports the PR adds or touches; entries without a linked failing CI run or a comment; one-off failures cited as justification.
- **Severity:** blocking · **Scope:** ci-baseline
- **Sources:** [ci.baseline.txt](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt); [Maintainer guide: Ports must be tested in at least one official triplet](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-be-tested-in-at-least-one-official-triplet); PRs: [#28332](https://github.com/microsoft/vcpkg/pull/28332#discussion_r1058958656), [#31084](https://github.com/microsoft/vcpkg/pull/31084#issuecomment-1522141731)

### CI-005: Use supports for real limits, baselines for lab limits

- **Rule:** Limits that apply to everyone (upstream doesn't support the platform, the build can't work there, or linkage restrictions known from `vcpkg_check_linkage`) belong in `supports`, sparing users from building dependencies only to fail; ci.baseline.txt only records the build lab's inability to test what users can build (missing SDK, old NDK, CI-only failure). Entries duplicating `supports` are CI errors, both baseline files must agree, and narrowing a dependency's `supports` requires updating its dependents.
- **Check:** Baseline additions for platforms upstream doesn't support; `supports` exclusions justified only by a CI failure; long-standing `fail` entries upstream won't fix, which belong in `supports`; when `supports` changes, grep ci.baseline.txt and ci.feature.baseline.txt for the port and its dependents.
- **Severity:** blocking · **Scope:** all
- **Sources:** [ci.baseline.txt](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt); [vcpkg.json: supports](https://learn.microsoft.com/vcpkg/reference/vcpkg-json#supports); PRs: [#54264](https://github.com/microsoft/vcpkg/pull/54264#discussion_r4458796014), [#51067](https://github.com/microsoft/vcpkg/pull/51067#issuecomment-4228927340)

### CI-006: Remove baseline entries the PR makes obsolete

- **Rule:** When a port, feature, or test port now builds, delete its stale `fail`, `skip`, or `cascade` entries from scripts/ci.baseline.txt and ci.feature.baseline.txt, since stale entries fail CI and hide future regressions. Try to learn why the entry existed so flaky ports aren't reintroduced; once it is removed, breaking that port counts as a regression.
- **Check:** CI "PASSING, REMOVE FROM FAIL LIST: <port>:<triplet>" or "passed but was marked expected to ..." errors; grep both baseline files for ports the PR fixes or updates.
- **Severity:** blocking · **Scope:** ci-baseline
- **Sources:** [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md); [ci.baseline.txt](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt); PRs: [#45287](https://github.com/microsoft/vcpkg/pull/45287#issuecomment-2843111760), [#51727](https://github.com/microsoft/vcpkg/pull/51727#issuecomment-4449273951)

### CI-007: Record unavoidable feature failures precisely in ci.feature.baseline.txt

- **Rule:** The feature tester reports every unrecorded failure as an error, so feature failures that can't be fixed must be recorded in scripts/ci.feature.baseline.txt with the state CI suggests: `feature-fails`, `combination-fails`, `cascade` (dependency unsupported, with a comment), or `options` only for legacy mutually exclusive or required features. Prefer supports-expression selectors such as `port[feat](!windows)` over per-triplet lines, comment each entry, mirror ci.baseline.txt `fail` entries, and format with `vcpkg format-feature-baseline`.
- **Check:** CI "ci.feature.baseline.txt: error: <port>[core,<feature>]:<triplet> ..." messages and their suggested states; diffs to ci.feature.baseline.txt lacking comments, using the wrong state, or left unformatted.
- **Severity:** blocking · **Scope:** ci-baseline
- **Sources:** [vcpkg x-test-features: --ci-feature-baseline](https://learn.microsoft.com/vcpkg/commands/test-features#--ci-feature-baseline); [vcpkg format-feature-baseline](https://learn.microsoft.com/vcpkg/commands/format-feature-baseline); [ci.feature.baseline.txt](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.feature.baseline.txt); PRs: [#48276](https://github.com/microsoft/vcpkg/pull/48276#issuecomment-3533960711), [#46147](https://github.com/microsoft/vcpkg/pull/46147#issuecomment-3083071317)

### CI-008: Skip mutually conflicting ports on every affected triplet

- **Rule:** Ports that can't coexist in one installed tree (e.g., libressl and openssl, kf5/kf6 pairs, ports installing files owned by others) must be marked `=skip` with a comment on every triplet where both would build, including newly supported ones. PR CI won't notice a missing skip, but the full scheduled run then fails with file conflicts; feature tests run isolated, so the skipped port's features are still tested.
- **Check:** When a port is added or its `supports` widens, check whether another port installs the same files on those triplets and whether skip entries cover all of them; FILE_CONFLICTS in CI logs.
- **Severity:** blocking · **Scope:** ci-baseline
- **Sources:** [Maintainer guide: Ports must install simultaneously](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-install-simultaneously); [ci.baseline.txt](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt); PRs: [#36022](https://github.com/microsoft/vcpkg/pull/36022#issuecomment-1876468846), [#35201](https://github.com/microsoft/vcpkg/pull/35201#discussion_r1398659869)

### CI-009: Choose fail, skip, and pass baseline states correctly

- **Rule:** Record a port broken on a triplet as `=fail`: PR CI skips it but scheduled runs still build it, so fixes are noticed. Reserve `=skip` for flaky or conflicting ports, always with a comment, since skipped ports are never built and hide both regressions and fixes. List vcpkg-ci test ports as `=pass` on every triplet where they should work, so a cascade is reported as a regression.
- **Check:** New `=skip` lines without a flakiness or conflict reason; vcpkg-ci-* `=fail` lines without matching `=pass` lines for other triplets; CI "cascaded, but it is required to pass".
- **Severity:** non-blocking · **Scope:** ci-baseline
- **Sources:** [ci.baseline.txt](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt); PRs: [#40278](https://github.com/microsoft/vcpkg/pull/40278#discussion_r1847649246), [#51160](https://github.com/microsoft/vcpkg/pull/51160#discussion_r3089029617)

### CI-010: Prove non-trivial packaging with a consumer build or test port

- **Rule:** CI only installs ports and runs post-build checks, so header-only or leaf ports, build-system surgery, custom configs or wrappers, unusual consumption models, and claimed target or usage fixes need evidence that consumers work. Add or extend a minimal `scripts/test_ports/vcpkg-ci-<port>` (or show a sample project) that links each claimed target through a real symbol via every advertised path (CMake, pkg-config, direct include-plus-link) in Release and Debug; heavy integration test ports are provisional.
- **Check:** Packaging or usage changes without a vcpkg-ci-* test or sample consumer; test ports that don't call a function from each target; vcpkg-ci-* logs in CI, or run them locally with `--overlay-ports=scripts/test_ports`.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#48264](https://github.com/microsoft/vcpkg/pull/48264#pullrequestreview-3467590773), [#43917](https://github.com/microsoft/vcpkg/pull/43917#discussion_r1969044776)

### CI-011: Verify changed sources with uncached builds on targeted triplets

- **Rule:** Binary-cache and asset-cache hits let CI pass or skip without rebuilding changed sources, and stale cache entries can cause hash mismatches unrelated to the PR. Reviewers therefore install from source with binary caching disabled (`--binarysource=clear`) on representative triplets, at least x64-windows or x64-linux plus those a fix targets (e.g., Android, arm64-windows), and state which triplets passed.
- **Check:** CI logs restoring cached packages or asset-cache downloads for ports whose sources changed; review comments listing the locally tested triplets.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** PRs: [#35898](https://github.com/microsoft/vcpkg/pull/35898#issuecomment-1911529113), [#37015](https://github.com/microsoft/vcpkg/pull/37015#issuecomment-1968414332)

### CI-012: Delist dead or untestable ports instead of baselining them

- **Rule:** When effectively dead dependents block an important update, or a port would fail or be skipped on every official CI triplet, maintainers may agree to delist it (and its dependents) rather than keep it untested. For broad upstream API removals, notify affected upstreams, allow 30 days, then patch or delist; porting many consumers to a new API via patches can amount to feature development, so waiting for upstream may be preferable.
- **Check:** Upstream activity or end-of-life status of failing dependents; ci.baseline or `supports` changes leaving a port untested everywhere; PR descriptions listing failing dependents with a fix-or-delist plan.
- **Severity:** non-blocking · **Scope:** port-update
- **Sources:** [Maintainer guide: Ports must be tested in at least one official triplet](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-be-tested-in-at-least-one-official-triplet); [Maintainer guide: Notify upstream owners for upstream-relevant patches](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#notify-upstream-owners-for-upstream-relevant-patches); PRs: [#42678](https://github.com/microsoft/vcpkg/pull/42678#issuecomment-2596234463), [#50690](https://github.com/microsoft/vcpkg/pull/50690#issuecomment-4209408149)

### CI-013: Test and report configurations CI doesn't cover

- **Rule:** For changes affecting configurations no CI triplet builds (community triplets such as wasm32-emscripten, cross builds for Android, MinGW, or arm64-linux, autotools build-triplet detection), the contributor must build locally and report the triplet, command, and outcome. Designs adding code paths or files that no CI triplet exercises are treated skeptically because they silently rot, and their contributor owns resulting breakage.
- **Check:** PRs touching cross-compilation logic or uncovered triplets without stated local results; features, overlay variants, or extra files that no CI triplet builds.
- **Severity:** non-blocking · **Scope:** all
- **Sources:** [Maintainer guide: Ports must be tested in at least one official triplet](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#ports-must-be-tested-in-at-least-one-official-triplet); PRs: [#33780](https://github.com/microsoft/vcpkg/pull/33780#issuecomment-1720718944), [#44602](https://github.com/microsoft/vcpkg/pull/44602#issuecomment-2753053017)

### CI-014: Prefer ports over CI image changes; isolate image PRs

- **Rule:** Don't fix CI by adding system packages to build images when the dependency can be a vcpkg port; heavy system packages clash with vcpkg-provided libraries. Necessary image changes go in a separate, justified PR to the scripts/azure-pipelines provisioning files and take effect only after the monthly Patch Tuesday image rebuild, so dependent port PRs wait under `depends:vm-update` or temporarily skip the affected feature; revert unneeded image changes.
- **Check:** Port PRs that also edit scripts/azure-pipelines image or provisioning files; ports requiring -dev system packages absent from the CI image.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** PRs: [#48304](https://github.com/microsoft/vcpkg/pull/48304#discussion_r2532971288), [#49486](https://github.com/microsoft/vcpkg/pull/49486#issuecomment-3797807568)

### CI-015: Don't treat classic-mode CI as proof of version constraints

- **Rule:** CI builds in classic mode with only the latest port versions, so it never exercises `version>=` minimums or overrides; versions-database validation (git-trees, constraints) runs in the x86-windows "Validate version files" step and the PR-check bot. Treat failures there as versions-database problems, not build failures.
- **Check:** Failures in the x86-windows "Validate version files" step or PR-check bot comments; PRs citing green CI as evidence that a version constraint works.
- **Severity:** advisory · **Scope:** versions
- **Sources:** PRs: [#54492](https://github.com/microsoft/vcpkg/pull/54492#issuecomment-6321513903), [#51007](https://github.com/microsoft/vcpkg/pull/51007#discussion_r3048975520)

### CI-016: Account for PR-CI scope and stale branches

- **Rule:** PR CI rebuilds only ports affected by the change and feature-tests only modified ports, so cascades and conflicts can differ from full scheduled CI. Editing ci.baseline.txt widens the rebuilt set and can surface unrelated or flaky failures, so avoid drive-by edits. When the "common mistakes" check fails on a branch more than about 50 commits behind master, update the branch before investigating.
- **Check:** Unrelated failures after ci.baseline.txt edits; baseline changes justified only by full-CI results; unexplained "common mistakes" failures on stale branches.
- **Severity:** advisory · **Scope:** all
- **Sources:** PRs: [#29568](https://github.com/microsoft/vcpkg/pull/29568#issuecomment-1524882570), [#28467](https://github.com/microsoft/vcpkg/pull/28467#issuecomment-1364547889)

## SCR: Scripts, tooling, triplets, and helper ports

### SCR-001: Add community triplets only for demonstrated, distinct use

- **Rule:** Add new triplets only under triplets/community, and only for a genuinely different configuration (as uwp or Emscripten are) that real users need and that isn't known to be broken. Variants that merely "complete the set" (extra -release or -static-md flavors), pin a toolset, or serve one project belong in overlay triplets. Official CI-tested triplets, including promotions from community, depend on CI budget a contributor PR can't provide.
- **Check:** New or moved files under triplets/: does the PR name actual users, show the triplet works (e.g., relocatable outputs), and configure something beyond recombining existing settings?
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [Maintainer guide: Triplets](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#triplets); PRs: [#37116](https://github.com/microsoft/vcpkg/pull/37116#issuecomment-1984892359), [#36181](https://github.com/microsoft/vcpkg/pull/36181#issuecomment-3422275672)

### SCR-002: Justify shared-script changes that force world rebuilds

- **Rule:** Changes to scripts/cmake, scripts/ports.cmake, or widely used helper ports alter many ports' ABI and rebuild the world, so treat them like vcpkg tool changes: give a detailed rationale and clear customer benefit, and prefer designs that limit the rebuild (a new function rather than a new mode). Cosmetic tweaks don't qualify, nor do single-port needs that existing per-call options (e.g., ADDITIONAL_MSYS_PACKAGES) cover; submit script changes separately from port updates.
- **Check:** Diffs under scripts/cmake, scripts/ports.cmake, scripts/buildsystems, or ports/vcpkg-*: is the change separate from port updates, justified in the description, and assessed for triplets CI doesn't test (e.g., dynamic Linux)?
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [PR review guide](https://github.com/microsoft/vcpkg/blob/master/.github/skills/shared/review-vcpkg-pr-guide.md); PRs: [#54450](https://github.com/microsoft/vcpkg/pull/54450#issuecomment-6408275467), [#48003](https://github.com/microsoft/vcpkg/pull/48003#discussion_r2479560761)

### SCR-003: Put new helper behavior in versioned helper ports

- **Rule:** Avoid changing the unversioned scripts/cmake build helpers (vcpkg_configure_make, vcpkg_build_make, vcpkg_configure_meson, ...), even for bug fixes: users can't pin them, so older port versions would silently change. Implement new behavior in the versioned helper port (vcpkg-make, vcpkg-tool-meson, vcpkg-cmake, ...) that ports adopt as a host dependency, and move ports to an existing vcpkg-* replacement instead of editing the frozen helper.
- **Check:** Diffs changing the semantics of scripts/cmake/vcpkg_configure_*.cmake, vcpkg_build_*.cmake, or other helpers that have a vcpkg-* replacement; make/autotools work outside ports/vcpkg-make.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [Maintainer guide: Avoid deprecated helper functions](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#avoid-deprecated-helper-functions); [PR review guide](https://github.com/microsoft/vcpkg/blob/master/.github/skills/shared/review-vcpkg-pr-guide.md); PRs: [#47024](https://github.com/microsoft/vcpkg/pull/47024#issuecomment-3372400865), [#31228](https://github.com/microsoft/vcpkg/pull/31228#issuecomment-1692369384)

### SCR-004: Keep helper and script changes backward compatible

- **Rule:** Changes to scripts/cmake functions, helper ports, and toolchain defaults must keep existing callers working, including older port versions, older baselines, and overlay ports. Never remove or repurpose arguments, add mandatory ones, change defaults callers rely on, emit options older tool versions reject, or turn failed builds into successes. Report newly detected misuse at "${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" (fatal in CI, a warning for users), not FATAL_ERROR.
- **Check:** Compare changed signatures, defaults, and emitted options in scripts/cmake/*.cmake and ports/vcpkg-* with existing callers (grep ports/); flag new message(FATAL_ERROR ...) for previously accepted input.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [CMake guidelines: Changing existing functions](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#changing-existing-functions); PRs: [#34546](https://github.com/microsoft/vcpkg/pull/34546#issuecomment-2045645999), [#33198](https://github.com/microsoft/vcpkg/pull/33198#discussion_r1623278505)

### SCR-005: Change generated ports through their generator or upstream

- **Rule:** Fix generated ports at their source, because regeneration overwrites hand edits. For boost-* ports, edit scripts/boost/generate-ports.ps1 (patch files go in the port directory; bump the port's $portVersions entry) and rerun it; vulkan-sdk-components data comes from its get-vulkan-sdk-components-info.ps1; azure-*-cpp ports are published by the Azure SDK release process, so send fixes to Azure/azure-sdk-for-cpp.
- **Check:** Diffs to ports/boost-*/, ports/azure-*-cpp/, or other generated manifests and portfiles without a matching generator or upstream change; rerun the generator and compare with the committed files.
- **Severity:** blocking · **Scope:** port-update
- **Sources:** PRs: [#40823](https://github.com/microsoft/vcpkg/pull/40823#issuecomment-2379826975), [#34393](https://github.com/microsoft/vcpkg/pull/34393#issuecomment-1757983039)

### SCR-006: Keep buildsystem integration compatible with existing users

- **Rule:** Changes to scripts/buildsystems (vcpkg.cmake, MSBuild props/targets), toolchains, installed CMake wrappers, and bootstrap scripts must preserve user overrides (e.g., VcpkgConfiguration) and per-manifest, per-triplet installed trees, keep working with the oldest supported CMake and MSBuild versions, and avoid concurrency or performance regressions. Bootstrap must never delete a working vcpkg before its replacement succeeds. Dropping support needs specific rationale, because customers keep older tools and setups.
- **Check:** Diffs to scripts/buildsystems/**, scripts/toolchains/*.cmake, vcpkg-cmake-wrapper.cmake files, or bootstrap scripts: unguarded newer CMake commands or policies, changed defaults, removed variables, files deleted before downloads succeed; run the cmake-user test port.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [CMake guidelines: CMake versions to require](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#cmake-versions-to-require); PRs: [#22086](https://github.com/microsoft/vcpkg/pull/22086#issuecomment-1205745012), [#24493](https://github.com/microsoft/vcpkg/pull/24493#issuecomment-1414442114)

### SCR-007: Structure helper ports per the script-port guidelines

- **Rule:** Helper (script) ports set VCPKG_POLICY_CMAKE_HELPER_PORT, install vcpkg-port-config.cmake into share/${PORT}, guard included files with include_guard(GLOBAL), explicitly include the helpers they depend on, install no headers, and preferably use version-date. Give each a focused purpose with vcpkg_<tool>_<verb> functions, separate from the tool port it drives, rather than a catch-all utility collection that grows without bound.
- **Check:** New or changed ports/vcpkg-*: helper-port policy, vcpkg-port-config.cmake location, include guards, version scheme, installed headers, and whether unrelated helpers are bundled together.
- **Severity:** blocking · **Scope:** helper-port
- **Sources:** [Authoring script ports](https://learn.microsoft.com/vcpkg/maintainers/authoring-script-ports); PRs: [#33198](https://github.com/microsoft/vcpkg/pull/33198#discussion_r1408245226), [#28084](https://github.com/microsoft/vcpkg/pull/28084#discussion_r1139499408)

### SCR-008: Include every build-affecting input in the ABI hash

- **Rule:** Any new script, triplet, or CI input that changes build outputs (files listed in VCPKG_POST_PORTFILE_INCLUDES, chainloaded toolchains, SDK or JDK files, CUDA versions on CI images) must feed the package ABI hash, e.g., via VCPKG_HASH_ADDITIONAL_FILES, or binary caches serve stale artifacts. Pass machine-specific paths through VCPKG_ENV_PASSTHROUGH_UNTRACKED, and keep diagnostic-only data out of the hash.
- **Check:** Changes to scripts/ports.cmake, toolchains, triplet variables, or CI images: does the ABI hash change whenever outputs can? Flag VCPKG_ENV_PASSTHROUGH used for install paths.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [Triplets: VCPKG_HASH_ADDITIONAL_FILES](https://learn.microsoft.com/vcpkg/users/triplets#vcpkg_hash_additional_files); PRs: [#25847](https://github.com/microsoft/vcpkg/pull/25847#pullrequestreview-2104003043), [#55118](https://github.com/microsoft/vcpkg/pull/55118#issuecomment-6996898146)

### SCR-009: Bump acquired tool versions only for needed changes

- **Rule:** Change versions of tools vcpkg acquires or requires (scripts/vcpkg-tools.json, acquire scripts, minimum-version checks) only for a needed fix or feature, coordinating CMake or PowerShell bumps with maintainers so they match the CI build lab; a CMake change is a world rebuild. Updates should not require port changes and must keep supported hosts working, but breakage on hosts outside the supported-hosts policy (distros over five years old) doesn't block.
- **Check:** Version changes in scripts/vcpkg-tools.json, vcpkg_find_acquire_program scripts, or minimum-version checks: is a required fix cited, do CI images match, and which supported distributions would lose support?
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [Supported hosts: Full support expected](https://learn.microsoft.com/vcpkg/concepts/supported-hosts#full-support-expected); PRs: [#52533](https://github.com/microsoft/vcpkg/pull/52533#pullrequestreview-4549461348), [#34433](https://github.com/microsoft/vcpkg/pull/34433#issuecomment-1760713130)

### SCR-010: Don't add new host-tool requirements

- **Rule:** Scripts and helper ports must not introduce new host-tool requirements (e.g., git-lfs, dumpbin) without a public use case, because ports start depending on them by accident; binary inspection belongs in vcpkg-tool. Ports should likewise avoid new host tools such as node when CMake can do the step or upstream can ship the artifact. autoconf, automake, and libtool are expected from the host system; ports providing them haven't been accepted.
- **Check:** New find_program or executable calls in scripts/cmake or ports/vcpkg-*; portfiles requiring node, npm, or similar just for generation steps; new ports packaging autotools.
- **Severity:** blocking · **Scope:** all
- **Sources:** PRs: [#22158](https://github.com/microsoft/vcpkg/pull/22158#issuecomment-1007076125), [#29743](https://github.com/microsoft/vcpkg/pull/29743#discussion_r1124986843)

### SCR-011: Keep VCPKG_TARGET_IS_* and architecture names canonical

- **Rule:** New VCPKG_TARGET_IS_<X> variables must mirror official CMake platform names (APPLE yes, APPLE_MOBILE no), and triplets or toolchains must never set VCPKG_TARGET_IS_*, because portfile logic must agree with platform-expression evaluation; only "unknown platform" defaults such as file suffixes may become triplet-overridable. Don't add alternate spellings of existing VCPKG_TARGET_ARCHITECTURE values (aarch64 for arm64), which break scripts and portfiles keyed on them.
- **Check:** Script diffs defining new VCPKG_TARGET_IS_* names; triplets or toolchains assigning VCPKG_TARGET_IS_* or exporting vcpkg-internal variables to projects; new architecture values or aliases.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** PRs: [#47816](https://github.com/microsoft/vcpkg/pull/47816#pullrequestreview-3346337052), [#55057](https://github.com/microsoft/vcpkg/pull/55057#issuecomment-6930123832)

### SCR-012: Don't rename helpers cosmetically; deprecate only after migrating callers

- **Rule:** Don't rename, merge, or reshuffle existing helper functions or helper ports for tidiness: old names must keep working anyway, so churn needs meaningful customer benefit. Deprecate a helper only after migrating all in-tree callers and documenting the mechanical replacement; deprecated functions keep accepting their arguments and warn at "${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" rather than fail.
- **Check:** PRs renaming scripts/cmake functions or ports/vcpkg-* without functional need; deprecations that leave callers in ports/, lack a migration recipe, or make old calls fail.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** [CMake guidelines: Changing existing functions](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#changing-existing-functions); PRs: [#37280](https://github.com/microsoft/vcpkg/pull/37280#issuecomment-1998536946), [#22523](https://github.com/microsoft/vcpkg/pull/22523#issuecomment-1092084628)

### SCR-013: Don't override CMake commands in vcpkg.cmake; use variables

- **Rule:** Don't add or extend overrides of CMake built-in commands (find_package, try_compile, ...) in scripts/buildsystems/vcpkg.cmake; upstream CMake treats this as undefined behavior, so use existing opt-in variables such as VCPKG_OVERRIDE_FIND_PACKAGE_NAME or wait for CMake fixes. Expose new per-project toolchain knobs as CMake variables, reserving environment variables for machine-wide resources; the toolchain never reads the triplet file.
- **Check:** New function() or macro() definitions in vcpkg.cmake that shadow CMake commands; new ENV{...} switches for per-project behavior; code expecting triplet variables inside vcpkg.cmake.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** PRs: [#24493](https://github.com/microsoft/vcpkg/pull/24493#issuecomment-1198489610), [#23195](https://github.com/microsoft/vcpkg/pull/23195#pullrequestreview-963795631)

### SCR-014: Add helper interfaces and triplet variables only when needed

- **Rule:** Add helper ports, helper functions, public options, or triplet variables only for a concrete, specified use case that existing mechanisms can't cover (vcpkg_add_to_path, per-call options, VCPKG_<LANG>_FLAGS, per-PORT triplet customization, VCPKG_CHAINLOAD_TOOLCHAIN_FILE), in a dedicated PR. Keep interfaces small, make heavy optional dependencies opt-in, and document every new parameter in MicrosoftDocs/vcpkg-docs; each option is permanent API that enlarges the configuration matrix.
- **Check:** New cmake_parse_arguments keywords, functions, or dependencies in scripts/cmake or ports/vcpkg-*, and new VCPKG_* triplet variables: is there a real caller, rationale, and docs update? Flag triplet lines restating defaults.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** [Triplets: Per-port customization](https://learn.microsoft.com/vcpkg/users/triplets#per-port-customization); PRs: [#44602](https://github.com/microsoft/vcpkg/pull/44602#issuecomment-3530349349), [#25361](https://github.com/microsoft/vcpkg/pull/25361#issuecomment-1164739626)

### SCR-015: Follow vcpkg CMake guidelines and naming in scripts

- **Rule:** Scripts and vcpkg-* helper ports use functions (not macros) with cmake_parse_arguments(PARSE_ARGV ... arg ...), reject unparsed arguments, quote expansions, loop with IN LISTS/ITEMS, avoid needless CACHE variables, and prefix internals with z_vcpkg_/Z_VCPKG_. Switches are zero-argument keywords (like DISABLE_MSVC_TRANSFORMATIONS), never compared to literals such as "ON". Names describe actual behavior or effect, not the caller (no NO_CONFIGURE on a configure function), and don't resemble global variables, which invites using the wrong identifier.
- **Check:** Changed functions in scripts/ or ports/vcpkg-*: macros, positional or boolean-valued parameters, missing arg_UNPARSED_ARGUMENTS checks, CACHE use, unprefixed globals, misleading names, or names resembling VCPKG_TARGET_IS_*.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** [CMake guidelines](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines); [CMake guidelines: Naming variables](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines#naming-variables); PRs: [#23846](https://github.com/microsoft/vcpkg/pull/23846#discussion_r841944701), [#39050](https://github.com/microsoft/vcpkg/pull/39050#discussion_r1806026786)

### SCR-016: Cover script and helper changes with test ports

- **Rule:** Exercise changes to scripts, toolchains, and helper ports in the matching scripts/test_ports port (unit-test-cmake, cmake-user, vcpkg-find-acquire-program, rpath-test, ...), updating it and its CI trigger in the same PR, since many script bugs only surface in use; a test CI can't run yet may be checked in disabled with a comment. Test ports are unversioned overlay ports: no x-add-version or versions/ entries, but keep their manifests formatted.
- **Check:** Diffs to scripts/cmake, scripts/buildsystems, scripts/toolchains, or ports/vcpkg-* without matching scripts/test_ports changes; CI regressions in cmake-user or unit-test-cmake; versions/ entries for test ports.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** PRs: [#45417](https://github.com/microsoft/vcpkg/pull/45417#issuecomment-2862047797), [#28693](https://github.com/microsoft/vcpkg/pull/28693#issuecomment-1381010981)

### SCR-017: Provide new build tools as vcpkg-tool-* ports

- **Rule:** Provide a new build tool as a vcpkg-tool-<name> port consumed as a host dependency and exposing a function through vcpkg-port-config.cmake, not by extending vcpkg_find_acquire_program or scripts/vcpkg-tools.json (reserved for tools needed before CMake runs, compressors, and binary-caching providers). vcpkg_find_acquire_program is being retired: its per-program scripts hold only program-specific details, honor user overrides, keep each version in its own tool_subdirectory, and aren't bumped for tools that have tool ports.
- **Check:** New vcpkg_find_acquire_program(<TOOL>).cmake files or vcpkg-tools.json entries; version, caching, or string logic added to acquire scripts; acquire-script version bumps for tools with a vcpkg-tool-* port.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** [Authoring script ports](https://learn.microsoft.com/vcpkg/maintainers/authoring-script-ports); PRs: [#30483](https://github.com/microsoft/vcpkg/pull/30483#issuecomment-1504673507), [#43309](https://github.com/microsoft/vcpkg/pull/43309#discussion_r1919431354)

### SCR-018: Fix shared build plumbing centrally, not per port

- **Rule:** Fix problems caused by vcpkg.cmake, toolchains, or shared flag handling in those scripts, generically for all build-system helpers (flags from vcpkg_cmake_get_vars/VCPKG_DETECTED_*), rather than with per-port workarounds that accumulate debt; RPATH/install-name relocation belongs in the generic post-build fixup (VCPKG_FIXUP_ELF_RPATH, VCPKG_FIXUP_MACHO_RPATH). Keep C and C++ flags separate (never push C++ flags into _CL_), forward flag strings without splitting on spaces, and preserve deliberately chosen past behavior.
- **Check:** Port patches or portfile code working around generic toolchain behavior; build-system-specific fixups inside vcpkg_cmake_get_vars; helpers mixing C and C++ flags or splitting them on spaces; reverts of deliberate script lines (check git history).
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** PRs: [#48512](https://github.com/microsoft/vcpkg/pull/48512#issuecomment-3588409633), [#31720](https://github.com/microsoft/vcpkg/pull/31720#issuecomment-1583292827)

### SCR-019: Decide cross-compilation from VCPKG_CROSSCOMPILING and processor

- **Rule:** Base cross-compilation decisions in scripts and toolchains (passing --host to configure, setting CMAKE_SYSTEM_NAME or CMAKE_CROSSCOMPILING) on VCPKG_CROSSCOMPILING or an explicit host-versus-target comparison of system name and processor, not name prefixes or extra cache variables, which misclassify builds. Another architecture on the same OS (arm64 Linux on x64 Linux) is cross-compiling; leave CMAKE_SYSTEM_NAME unset only when system and processor both match the host.
- **Check:** Diffs to scripts/toolchains/*.cmake, make/configure helpers, or vcpkg_cmake_configure logic keyed on triplet-name prefixes, comparing only CMAKE_SYSTEM_NAME with CMAKE_HOST_SYSTEM_NAME, or forcing CMAKE_CROSSCOMPILING.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** PRs: [#22331](https://github.com/microsoft/vcpkg/pull/22331#issuecomment-1030758825), [#37734](https://github.com/microsoft/vcpkg/pull/37734#issuecomment-2040995861)

### SCR-020: Keep built-in toolchains general-purpose

- **Rule:** vcpkg's toolchains and triplets use safe general-purpose defaults rather than risky ones like /fp:fast, and don't hard-code compiler or tool names and paths; use find_program honoring user input, leaving fixed values to custom toolchains. Put platform defaults such as the Android API level in triplet files where possible, and set toolchain values as regular variables rather than CACHE ... FORCE (use INTERNAL if caching is unavoidable).
- **Check:** Diffs to scripts/toolchains/*.cmake or triplets/*.cmake adding aggressive optimization flags, fixed tool names or paths, hard-coded platform values, or CACHE STRING "" FORCE entries.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** PRs: [#29210](https://github.com/microsoft/vcpkg/pull/29210#discussion_r1088690294), [#35084](https://github.com/microsoft/vcpkg/pull/35084#discussion_r1401511455)

### SCR-021: Make script diagnostics accurate, actionable, and fail-safe

- **Rule:** Helper scripts must check the result of every external command they run (COMMAND_ERROR_IS_FATAL ANY or an explicit result variable), consistently. Errors should tell users how to fix the problem and print the inputs behind the decision (e.g., VCPKG_TARGET_ARCHITECTURE, ENV{VisualStudioVersion}). Friendly hints such as "install the Windows SDK" may fire only on output that unambiguously identifies that cause, since misleading advice is worse than none.
- **Check:** execute_process or vcpkg_execute_* calls without result checks; new FATAL_ERROR text lacking values or remediation; MATCHES branches mapping generic errors ("The system cannot find the file specified") to installation advice.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** PRs: [#39889](https://github.com/microsoft/vcpkg/pull/39889#discussion_r1861245028), [#26339](https://github.com/microsoft/vcpkg/pull/26339#discussion_r955268159)

### SCR-022: Keep tool logic in vcpkg-tool; require matching vcpkg versions

- **Rule:** Implement CI and tool behavior (test-result publishing, version handling, binary inspection) in microsoft/vcpkg-tool rather than as growing PowerShell or CMake scripts here, which become impenetrable. When ports or scripts rely on newer vcpkg behavior, raise vcpkg_minimum_required in scripts/ports.cmake so outdated executables fail clearly. vcpkg z-* commands are internal interfaces: don't document them or build external workflows on them.
- **Check:** Substantial new logic under scripts/ or pipeline YAML that the vcpkg executable owns; script changes needing new tool features without a vcpkg_minimum_required bump; docs describing z-* commands.
- **Severity:** non-blocking · **Scope:** scripts
- **Sources:** [vcpkg_minimum_required](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_minimum_required); PRs: [#23477](https://github.com/microsoft/vcpkg/pull/23477#issuecomment-1089178145), [#27692](https://github.com/microsoft/vcpkg/pull/27692#issuecomment-1414418816)

### SCR-023: Send documentation changes to MicrosoftDocs/vcpkg-docs

- **Rule:** vcpkg documentation lives in MicrosoftDocs/vcpkg-docs and is published at learn.microsoft.com/vcpkg. PRs that add or edit documentation under `docs/` in microsoft/vcpkg are closed and redirected there, and links should point to learn.microsoft.com rather than `docs/` paths in this repository.
- **Check:** Diffs adding or editing Markdown under `docs/`; new links to `github.com/microsoft/vcpkg/blob/master/docs/...`.
- **Severity:** blocking · **Scope:** scripts
- **Sources:** PRs: [#29121](https://github.com/microsoft/vcpkg/pull/29121#issuecomment-1425723436), [#19692](https://github.com/microsoft/vcpkg/pull/19692#issuecomment-1426534451)

## Sources and method

These rules were compiled on 2026-11-24 from two kinds of sources:

- **Documentation:**
  - The [maintainer guide](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide).
  - The [PR review checklist](https://learn.microsoft.com/vcpkg/contributing/pr-review-checklist).
  - The [CMake style guide](https://learn.microsoft.com/vcpkg/contributing/cmake-guidelines).
  - The [port policies](https://learn.microsoft.com/vcpkg/reference/policies).
  - The [installation tree layout](https://learn.microsoft.com/vcpkg/reference/installation-tree-layout).
  - The [vcpkg.json reference](https://learn.microsoft.com/vcpkg/reference/vcpkg-json).
  - The [versioning reference](https://learn.microsoft.com/vcpkg/users/versioning).
  - The [usage documentation](https://learn.microsoft.com/vcpkg/maintainers/handling-usage-files).
  - The [script ports](https://learn.microsoft.com/vcpkg/maintainers/authoring-script-ports) and [host dependencies](https://learn.microsoft.com/vcpkg/users/host-dependencies) guides.
  - The [helper function reference](https://learn.microsoft.com/vcpkg/maintainers/functions/vcpkg_cmake_configure).
  - Repository files: the [PR template](https://github.com/microsoft/vcpkg/blob/master/.github/pull_request_template.md), the [common mistakes workflow](https://github.com/microsoft/vcpkg/blob/master/.github/workflows/untrustedPR.yml), the [CI baseline](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt), [CONTRIBUTING.md](https://github.com/microsoft/vcpkg/blob/master/CONTRIBUTING.md), and [review-vcpkg-pr-guide.md](review-vcpkg-pr-guide.md).
- **Review history:** Every closed pull request in microsoft/vcpkg, from 2016-09 to 2026-11:
  - 30,759 closed PRs: 25,376 merged and 5,383 closed without merging.
  - 51,358 inline review comments.
  - 86,546 conversation comments.
  - 17,069 reviews.

The review history was distilled in several steps:

1. Comments by PR authors, bots, and trivial comments such as thanks or pings were removed. 73,291 substantive reviewer comments remained.
2. The remaining comments were bucketed by topic. 4,350 representative comments were then sampled, favoring:
   - Text that maintainers repeat as canned feedback.
   - The 45 most active reviewers.
   - Recent years.
   - The last reviewer comments on rejected PRs.
3. Candidate rules were extracted from the sample and merged with the documented policy. Duplicates were consolidated, and practices that current tooling has made obsolete were dropped.

Evidence links point to individual review comments. Practice can change over time, so prefer the most recent documentation when it conflicts with an older comment.
