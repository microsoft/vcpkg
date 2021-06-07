# CMake Guidelines

We expect that all CMake scripts that are either:

- In the `scripts/` directory, or
- In a `vcpkg-*` port

should follow the guidelines laid out in this document.
Existing scripts may not follow these guidelines yet;
it is expected that we will continue to update old scripts to fall in line with these guidelines.

These guidelines are intended to create stability in our scripts.
We hope that they will make both forwards and backwards compatibility easier.

## The Guidelines

- We always use `cmake_parse_arguments` rather than function parameters, or referring to `${ARG<N>}`.
  - This doesn't need to be followed for "script-local helper functions"
  - Exception: exclusively positional parameters, like out variables.
    - In this case, positional parameters should be put in the function declaration
      (rather than using `${ARG<N>}`), and should be named according to local rules
      (i.e. `snake_case`).
    - Exception: positional parameters that are optional should be given a name via
      `set(argument_name "${ARG<N>}") after checking `${ARGC}`.
- There are no unparsed or unused arguments. Always check for `ARGN` or `arg_UNPARSED_ARGUMENTS`,
  and either `FATAL_ERROR`, or `WARN` if necessary for backwards compatibility.
- All `cmake_parse_arguments` use `PARSE_ARGV` for resistance to embedded semicolons.
- All `foreach` loops use `IN LISTS` for resistance to embedded semicolons.
- The variables `${ARGV}` and `${ARGN}` are unreferenced, except in helpful messages to the user.
  - (i.e., `message(FATAL_ERROR "blah was passed extra arguments: ${ARGN}")`)
- We always use functions, not macros or top level code.
  - Exception: `vcpkg.cmake`'s `find_package`
- Scripts in the scripts tree should not be expected to need changes as part of normal operation. (For example, `vcpkg_acquire_msys` has hard coded specific packages and versions thereof used which we believe is unacceptable)
- All non-splat variable expansions are in quotes "".
- There are no "pointer" parameters (where a user passes a variable name rather than the contents) except for out parameters.
- Undefined names are not referenced.
- Out parameters only set `PARENT_SCOPE`.
- `CACHE` variables are not used, except for internal global variables which are used to avoid duplicating work.
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
