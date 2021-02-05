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
* Local variables are not named anything special (not `Z_`).
* Internal global variable names are named `Z_VCPKG_`.
* External experimental global variable names are named `X_VCPKG_`.
* Internal functions are named `z_vcpkg_*`
* Public global variables are named `VCPKG_`.
* All non-splat variable expansions are in quotes "".
* There are no "pointer" parameters (where a user passes a variable name rather than the contents) except for out parameters.
* Undefined names are not referenced.
* Out parameters only set `PARENT_SCOPE`.
* `CACHE` variables are not used.
* `include()`s are removed and fixes to `port.cmake` et al. are made as necessary to avoid this.

## Prognosis

Not everything should remain in the scripts tree. As part of this audit, each helper will be dealt with in one of several ways:

* Stay in scripts tree
* Deleted outright
* Moved to a tool port
* Deprecated

# Current todo list

Changes to be made:

* ~~`execute_process`' `OVERRIDDEN_EXECUTE_PROCESS` should get `Z_`~~
* ~~`execute_process`' override should be a function rather than a macro~~
* Most of vcpkg_acquire_msys needs to become a tool port, except for the content of the mirror list.
* Calls to vcpkg_acquire_msys that call PACKAGES are deprecated; the tool port will use NO_DEFAULT_PACKAGES DIRECT_PACKAGES
