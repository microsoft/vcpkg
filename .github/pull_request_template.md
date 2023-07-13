<!-- If your PR fixes issues, please note that here by adding "Fixes #NNNNNN." for each fixed issue on separate lines. -->

<!-- If you are still working on the PR, open it as a Draft: https://github.blog/2019-02-14-introducing-draft-pull-requests/ -->

<!-- If this PR updates an existing port, please uncomment and fill out this checklist:

- [ ] Changes comply with the [maintainer guide](https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/contributing/maintainer-guide.md)
- [ ] SHA512s are updated for each updated download
- [ ] The "supports" clause reflects platforms that may be fixed by this new version
- [ ] Any fixed [CI baseline](https://github.com/microsoft/vcpkg/blob/master/scripts/ci.baseline.txt) entries are removed from that file.
- [ ] Any patches that are no longer applied are deleted from the port's directory.
- [ ] The version database is fixed by rerunning `./vcpkg x-add-version --all` and committing the result.
- [ ] Only one version is added to each modified port's versions file.

END OF PORT UPDATE CHECKLIST (delete this line) -->

<!-- If this PR adds a new port, please uncomment and fill out this checklist:

- [ ] Changes comply with the [maintainer guide](https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/contributing/maintainer-guide.md)
- [ ] The name of the port matches an existing name for this component on https://repology.org/ if possible, and/or is strongly associated with that component on search engines.
- [ ] Optional dependencies are resolved in exactly one way. For example, if the component is built with CMake, all `find_package` calls are REQUIRED, are satisfied by `vcpkg.json`'s declared dependencies, or disabled with [CMAKE_DISABLE_FIND_PACKAGE_Xxx](https://cmake.org/cmake/help/latest/variable/CMAKE_DISABLE_FIND_PACKAGE_PackageName.html)
- [ ] The versioning scheme in `vcpkg.json` matches what upstream says.
- [ ] The license declaration in `vcpkg.json` matches what upstream says.
- [ ] The installed as the "copyright" file matches what upstream says.
- [ ] The source code of the component installed comes from an authoritative source.
- [ ] The generated "usage text" is accurate. See [adding-usage](https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/examples/adding-usage.md) for context.
- [ ] The version database is fixed by rerunning `./vcpkg x-add-version --all` and committing the result.
- [ ] Only one version is in the new port's versions file.
- [ ] Only one version is added to each modified port's versions file.

END OF NEW PORT CHECKLIST (delete this line) -->
