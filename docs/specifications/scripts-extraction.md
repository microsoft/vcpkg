# Scripts Tree Extraction

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

## Background

We extracted vcpkg-tool as part of a future wherein Registries are the primary mechanism for interacting with the ports tree, which would allow the vcpkg tool and associated artifacts to be deployed and figure the rest out on their own. Unfortunately, we have concurrently edited things in the so called "scripts" tree which lives in support of ports but really probably belongs in the vcpkg-tool repo.

Moreover, as part of stabilizing registries, the interface exposed by the scripts tree becomes contractual rather than something we can change in concert with ports, since we can no longer see the universe of ports to validate that changes are correct.

To that end we are auditing the contents of the scripts tree to make sure it is a solid foundation for future work.

The work list is contained in [Issue #16188].

[Issue #16188]: https://github.com/microsoft/vcpkg/issues/16188

## Audit Points

The following are assertions we want to be able to make about the contents of the scripts tree. Note that this does *not* refer to `vcpkg.cmake` since that needs to work with older versions of cmake.

These are design ideals that we may break in some limited cases where that makes sense.

- We always use `cmake_parse_arguments` rather than function parameters, or referring to `${ARG<N>}`.
  - Exception: there are exclusively positional parameters. This should be _very rare_.
    - In this case, positional parameters should be put in the function declaration
      (rather than using `${ARG<N>}`), and should be named according to local rules
      (i.e. `snake_case`).
    - Exception: positional parameters that are optional should be given a name via
      `set(argument_name "${ARG<N>}") after checking `${ARGC}`.
  - Note: in cases where there are positional parameters along with non-positional parameters, positional parameters should be referred to by `arg_UNPARSED_ARGUMENTS`.
- All `cmake_parse_arguments` use `PARSE_ARGV` for resistance to embedded semicolons.
- All `foreach` loops use `IN LISTS` for resistance to embedded semicolons.
- The variable `${ARGV}` is unreferenced.
- We use functions, not macros or top level code.
- Scripts in the scripts tree should not be expected to need changes as part of normal operation. (For example, `vcpkg_acquire_msys` has hard coded specific packages and versions thereof used which we believe is unacceptable)
- All non-splat variable expansions are in quotes "".
- There are no "pointer" parameters (where a user passes a variable name rather than the contents) except for out parameters.
- Undefined names are not referenced.
- Out parameters only set `PARENT_SCOPE`.
- `CACHE` variables are not used.
- `include()`s are removed and fixes to `port.cmake` et al. are made as necessary to avoid this.
- `foreach(RANGE)`'s arguments _must always be_ natural numbers, and `<start>` _must always be_ less than or equal to `<stop>`.
  - This should be checked.

### Naming Variables

- `cmake_parse_arguments`: set prefix to `"arg"`
- local variables are named `snake_case`
- Internal global variable names are named `Z_VCPKG_`.
- External experimental global variable names are named `X_VCPKG_`.
- Internal functions are named `z_vcpkg_*`
  - Functions which are internal to a single function (i.e., helper functions)
    are named `[z_]<func>_<name>`, where `<func>` is the name of the function they are
    a helper to, and `<name>` is what the helper function does.
    - `z_` should be added to the front if `<func>` doesn't have a `z_`,
      but don't name a helper function `z_z_foo_bar`.
- Public global variables are named `VCPKG_`.

## Prognosis

Not everything should remain in the scripts tree. As part of this audit, each helper will be dealt with in one of several ways:

- Stay in scripts tree
- Deleted outright
- Moved to a tool port
- Deprecated
