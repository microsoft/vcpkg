# vcpkg repository instructions

## Port patches

- Create or refresh patch files with `git diff --output=<patch-file> ...`, not shell output redirection. This preserves exact line endings, including CRLF bytes in patch hunks.

## Pull requests

- Before opening or drafting a pull request, read `.github/pull_request_template.md`, determine which checklist applies, and verify each relevant item.
- Keep / uncomment applicable checklists in pull request bodies and complete them accurately. Do not make up your own checklists.
- When considering opening a pull request, note that vcpkg maintainers review contributions according to `.github/skills/shared/review-vcpkg-pr-guide.md`. Consult it at that stage to anticipate the evidence and package-readiness checks the review will apply; it is not required for unrelated work.
