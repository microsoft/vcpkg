# vcpkg_tool_release_process

This document describes the acceptance criteria / process we use when doing a vcpkg-tool update,
such as https://github.com/microsoft/vcpkg/pull/23757

1. Verify that all tests etc. are passing in the vcpkg-tool repo's `main` branch, and that the
  contents therein are acceptable for release. (Steps after this will sign code there, so this
  review is responsible gating what has access to code signing.)
2. On your machine, in a prompt changed to the vcpkg-tool repo,
  `git fetch origin && git push internal origin/main:main`
  (This assumes that `origin` is https://github.com/microsoft/vcpkg-tool, and internal is
  https://devdiv.visualstudio.com/DevDiv/_git/vcpkg)
3. Monitor the resulting signed build at:
  https://devdiv.visualstudio.com/DefaultCollection/DevDiv/_build?definitionId=13610
  and/or manually submit one. (The push is supposed to automatically submit a build but that
  has been somewhat unstable at the time of this writing.)
4. The signed build will automatically create a draft GitHub release at
  https://github.com/microsoft/vcpkg-tool/releases . Erase the contents filled in there and press
  the "auto generate release notes" button. Manually remove any entries created by the automated
  localization tools which will start with `* LEGO: Pull request from juno/`.
5. Publish that draft release as "pre-release".
6. Smoke test the 'one liner' installer: (Where 2022-03-30 is replaced with the right release name)
    * Powershell:
        `iex (iwr https://github.com/microsoft/vcpkg-tool/releases/download/2022-03-30/vcpkg-init.ps1)`
    * Batch:
        `curl -L -o vcpkg-init.cmd https://github.com/microsoft/vcpkg-tool/releases/download/2022-03-30/vcpkg-init.ps1 && .\vcpkg-init.cmd`
    * Bash:
        `. <(curl https://github.com/microsoft/vcpkg-tool/releases/download/2022-03-30/vcpkg-init.sh -L)`
7. FIXME FIXME FIXME Embedded scenarios go here
8. In the vcpkg repo, draft a PR which updates `bootstrap-vcpkg.sh` and `boostrap-vcpkg.ps1`
  with the new release date, and update SHAs as appropriate in the .sh script. (For example, see
  https://github.com/microsoft/vcpkg/pull/23757)
9. Submit a new full tree rebuild by https://dev.azure.com/vcpkg/public/_build?definitionId=29
  (microsoft.vcpkg.ci as of this writing) and queue a new build targeting branch
  `refs/pull/ The PR number created in the previous step /head` (for example
  `refs/pull/24131/head`
  https://dev.azure.com/vcpkg/public/_build/results?buildId=70703&view=results)
10. (Probably the next day) Check over the failures and ensure any differences with the most recent
  full rebuild using the previous tool version are understood.
11. Merge the tool update PR.
12. Change the github release in vcpkg-tool from "prerelease" to "release". (This automatically
  updates the aka.ms links)
