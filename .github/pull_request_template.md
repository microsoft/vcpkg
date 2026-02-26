<!-- If your PR fixes issues, please note that here by adding "Fixes #NNNNNN." for each fixed issue on separate lines. -->

<!-- If you are still working on the PR, open it as a Draft: https://github.blog/2019-02-14-introducing-draft-pull-requests/. -->

<!-- If this PR updates an existing port, please uncomment and fill out this checklist:

- [ ] Changes comply with the [maintainer guide](https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/contributing/maintainer-guide.md).
- [ ] SHA512s are updated for each updated download.
- [ ] The "supports" clause reflects platforms that may be fixed by this new version, or no changes were necessary.
- [ ] Any fixed [CI baseline](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt) and [CI feature baseline](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.feature.baseline.txt) entries are removed from that file, or no entries needed to be changed.
- [ ] All patch files in the port are applied and succeed.
- [ ] The version database is fixed by rerunning `./vcpkg x-add-version --all` and committing the result.
- [ ] Exactly one version is added in each modified versions file.

END OF PORT UPDATE CHECKLIST (delete this line) -->

<!-- If this PR adds a new port, please uncomment and fill out this checklist:

- [ ] Changes comply with the [maintainer guide](https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/contributing/maintainer-guide.md).
- [ ] The packaged project shows strong association with the chosen port name. Check this box if at least one of the following criteria is met:
    - [ ] The project is in Repology: https://repology.org/<PORT NAME>/versions
    - [ ] The project is amongst the first web search results for "<PORT NAME>" or "<PORT NAME> C++". Include a screenshot of the search engine results in the PR.
    - [ ] The port name follows the 'GitHubOrg-GitHubRepo' form or equivalent `Owner-Project` form.
- [ ] Optional dependencies of the build are all controlled by the port. A dependency is controlled if it is declared an unconditional dependency in `vcpkg.json`, or explicitly disabled through patches or build system arguments such as [CMAKE_DISABLE_FIND_PACKAGE_Xxx](https://cmake.org/cmake/help/latest/variable/CMAKE_DISABLE_FIND_PACKAGE_PackageName.html) or [VCPKG_LOCK_FIND_PACKAGE](https://learn.microsoft.com/vcpkg/users/buildsystems/cmake-integration#vcpkg_lock_find_package_pkg)
- [ ] The versioning scheme in `vcpkg.json` matches what upstream says.
- [ ] The license declaration in `vcpkg.json` matches what upstream says.
- [ ] The installed as the "copyright" file matches what upstream says.
- [ ] The source code of the component installed comes from an authoritative source.
- [ ] The generated "usage text" is brief and accurate. See [adding-usage](https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/examples/adding-usage.md) for context. Don't add a usage file if the automatically generated usage is correct.
- [ ] The version database is fixed by rerunning `./vcpkg x-add-version --all` and committing the result.
- [ ] Exactly one version is added in each modified versions file.

END OF NEW PORT CHECKLIST (delete this line) -->
