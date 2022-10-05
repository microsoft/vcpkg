# vcpkg_tool_release_process

This document describes the acceptance criteria / process we use when doing a vcpkg-tool update,
such as https://github.com/microsoft/vcpkg/pull/23757

1. Verify that all tests etc. are passing in the vcpkg-tool repo's `main` branch, and that the
  contents therein are acceptable for release. (Steps after this will sign code there, so this
  review is responsible gating what has access to code signing.)
2. Check that the changes there are in fact the changes that we want in that release. (Be aware,
  you are responsible for what is about to be signed with a Microsoft code signing certificate by
  proceeding)
3. Submit a new full tree rebuild by https://dev.azure.com/vcpkg/public/_build?definitionId=29
  (microsoft.vcpkg.ci as of this writing) and queue a new build with the vcpkg-tool SHA overridden
  to the one you wish to use. Example:
  https://dev.azure.com/vcpkg/public/_build/results?buildId=73664&view=results
4. (Probably the next day) Check over the failures and ensure any differences with the most recent
  full rebuild using the previous tool version are understood.
5. On your machine, in a prompt changed to the vcpkg-tool repo,
  `git fetch https://github.com/microsoft/vcpkg-tool main && git switch -d FETCH_HEAD`
6. `git push https://devdiv.visualstudio.com/DevDiv/_git/vcpkg FETCH_HEAD:main`
7. Monitor the resulting signed build at:
  https://devdiv.visualstudio.com/DefaultCollection/DevDiv/_build?definitionId=13610
  and/or manually submit one. (The push is supposed to automatically submit a build but that
  has been somewhat unstable at the time of this writing.)
8. The signed build will automatically create a draft GitHub release at
  https://github.com/microsoft/vcpkg-tool/releases . Erase the contents filled in there and press
  the "auto generate release notes" button. Manually remove any entries created by the automated
  localization tools which will start with `* LEGO: Pull request from juno/`.
9. Publish that draft release as "pre-release".
10. Clean up a machine for the following tests:
  * Delete `VCPKG_DOWNLOADS/artifacts` (which forces artifacts to be reacquired)
  * Delete `LOCALAPPDATA/vcpkg` (which forces registries to be reacquired)
11. Smoke test the 'one liner' installer: (Where 2022-06-15 is replaced with the right release name)
    * Powershell:
        `iex (iwr https://github.com/microsoft/vcpkg-tool/releases/download/2022-06-15/vcpkg-init.ps1)`
    * Batch:
        `curl -L -o vcpkg-init.cmd https://github.com/microsoft/vcpkg-tool/releases/download/2022-06-15/vcpkg-init.ps1 && .\vcpkg-init.cmd`
    * Bash:
        `. <(curl https://github.com/microsoft/vcpkg-tool/releases/download/2022-06-15/vcpkg-init -L)`
12. Test that embedded scenarios work for vcpkg-artifacts:
    Ensure that none of the following report errors:
    1. git clone https://github.com/some-example/blink/
    2. cd blink
    3. vcpkg activate
    4. idf.py set-target ESP32
    5. cd build
    6. ninja
13. In the vcpkg repo, draft a PR which updates `bootstrap-vcpkg.sh` and `boostrap-vcpkg.ps1`
  with the new release date, and update SHAs as appropriate in the .sh script. (For example, see
  https://github.com/microsoft/vcpkg/pull/23757)
15. Merge the tool update PR.
16. Change the github release in vcpkg-tool from "prerelease" to "release". (This automatically
  updates the aka.ms links)
