# Scripts Tree Extraction

## Background

We extracted vcpkg-tool as part of a future wherein Registries are the primary mechanism for interacting with the ports tree, which would allow the vcpkg tool and associated artifacts to be deployed and figure the rest out on their own. Unfortunately, we have concurrently edited things in the so called "scripts" tree which lives in support of ports but really probably belongs in the vcpkg-tool repo.

Moreover, as part of stabilizing registries, the interface exposed by the scripts tree becomes contractual rather than something we can change in concert with ports, since we can no longer see the universe of ports to validate that changes are correct.

To that end we are auditing the contents of the scripts tree to make sure it is a solid foundation for future work.

## Audit Points

The following are assertions we want to be able to make about the contents of the scripts tree. Note that this does *not* refer to `vcpkg.cmake` since that needs to work with older versions of cmake.

These are design ideals that we may break in some limited cases where that makes sense.

* We always use `cmake_parse_arguments` rather than function arguments.
* All `cmake_parse_arguments` use `PARSE_ARGV` for resistance to embedded semicolons.
* All `foreach` loops use `IN LISTS` for resistance to embedded semicolons.
* The variable `${ARGV}` is unreferenced.
* We use functions, not macros or top level code.
* Scripts in the scripts tree should not be expected to need changes as part of normal operation. (For example, `vcpkg_acquire_msys` has hard coded specific packages and versions thereof used which we believe is unacceptable)
* All non-splat variable expansions are in quotes "".
* There are no "pointer" parameters (where a user passes a variable name rather than the contents) except for out parameters.
* Undefined names are not referenced.
* Out parameters only set `PARENT_SCOPE`.
* `CACHE` variables are not used.
* `include()`s are removed and fixes to `port.cmake` et al. are made as necessary to avoid this.

### Naming Variables

* `cmake_parse_arguments`: set prefix to `"arg"`
* local variables are named `snake_case`
* Internal global variable names are named `Z_VCPKG_`.
* External experimental global variable names are named `X_VCPKG_`.
* Internal functions are named `z_vcpkg_*`
* Public global variables are named `VCPKG_`.

## Prognosis

Not everything should remain in the scripts tree. As part of this audit, each helper will be dealt with in one of several ways:

* Stay in scripts tree
* Deleted outright
* Moved to a tool port
* Deprecated

# Current todo list

Notes:
- Every `vcpkg_*_<buildsystem>` should be extracted to a single `<buildsystem>` port

Changes to be made:

- [x] `execute_process`:
  - [x] `execute_process`' `OVERRIDDEN_EXECUTE_PROCESS` should get `Z_`
  - [x] `execute_process`' override should be a function rather than a macro
- [ ] `vcpkg_acquire_msys`:
  - [ ] Most of vcpkg_acquire_msys needs to become a tool port, except for the content of the mirror list.
  - [ ] Calls to vcpkg_acquire_msys that call PACKAGES are deprecated; the tool port will use NO_DEFAULT_PACKAGES DIRECT_PACKAGES
- [ ] `vcpkg_add_to_path`:
  - [ ] audit
- [ ] `vcpkg_apply_patches`:
  - [ ] audit
  - [ ] deprecate, add `z_vcpkg_apply_patches` as an internal function
- [ ] `vcpkg_build_cmake`:
  - [ ] extract to ports
  - [ ] audit
- [ ] `vcpkg_build_gn`:
  - [ ] audit
  - [ ] deprecate in favor of `vcpkg_build_ninja`
- [ ] `vcpkg_build_make`:
  - [ ] extract to ports
  - [ ] audit
  - [ ] remove/deprecate `ENABLE_INSTALL` (depending on whether it's used) (see also `INSTALL_TARGET`)
  - [ ] look and see if `MAKEFILE` is used usefully vs `SUBPATH`; if not, deprecate/remove depending on whether it's used
- [ ] `vcpkg_build_msbuild`:
  - [ ] deprecate
  - [ ] audit
  - [ ] update modern ports to use `vcpkg_install_msbuild()`
- [ ] `vcpkg_build_ninja`:
  - [ ] extract to ports
  - [ ] audit
- [ ] `vcpkg_build_nmake`:
  - [ ] extract to ports
  - [ ] audit
- [ ] `vcpkg_build_qmake`:
  - [ ] extract to ports
  - [ ] audit
- [ ] `vcpkg_buildpath_length_warning`:
  - [ ] audit
- [ ] `vcpkg_check_features`:
  - [ ] audit
- [ ] `vcpkg_check_linkage`:
  - [ ] audit
- [ ] `vcpkg_clean_executables_in_bin`:
  - [ ] deprecate, rename to `z_vcpkg_clean_executables_in_bin`
  - [ ] audit
- [ ] `vcpkg_clean_msbuild`:
  - [ ] extract to port
  - [ ] audit
- [ ] `vcpkg_common_definitions`:
  - [ ] audit
- [x] `vcpkg_common_functions`:
  - already deprecated
- [ ] `vcpkg_configure_cmake`:
  - [ ] extract to port
  - [ ] audit
- [ ] `vcpkg_configure_gn`:
  - [ ] extract to port
  - [ ] audit
- [ ] `vcpkg_configure_make`:
  - [ ] extract to port
  - [ ] audit: _serious_ work
  - Notes: use xcopy or robocopy
- [ ] `vcpkg_configure_meson`:
  - [ ] extract to port
  - [ ] audit
- [ ] `vcpkg_configure_qmake`:
  - [ ] extract to port
  - [ ] audit
- [ ] `vcpkg_copy_pdbs`:
  - [ ] audit
  - [ ] we may want to consider baking this into the tool, with a policy for disabling it
- [ ] `vcpkg_copy_sources`:
  - [ ] add to scripts
- [ ] `vcpkg_copy_tool_dependencies`:
  - [ ] add macOS stuff
  - [ ] need to implement this into the vcpkg tool as opposed to using scripts
