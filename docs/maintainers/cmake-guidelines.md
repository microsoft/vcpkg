# CMake Guidelines

We expect that all CMake scripts that are either:

- In the `scripts/` directory, or
- In a `vcpkg-*` port

should follow the guidelines laid out in this document.
Existing scripts may not follow these guidelines yet;
it is expected that we will continue to update old scripts
to fall in line with these guidelines.

These guidelines are intended to create stability in our scripts.
We hope that they will make both forwards and backwards compatibility easier.

## The Guidelines

- We always use `cmake_parse_arguments` rather than function parameters,
  or referring to `${ARG<N>}`.
  - This doesn't need to be followed for "script-local helper functions"
  - Exception: exclusively positional parameters, like out variables.
    - In this case, positional parameters should be put in the function
      declaration (rather than using `${ARG<N>}`),
      and should be named according to local rules (i.e. `snake_case`).
    - Exception: positional parameters that are optional should be
      given a name via `set(argument_name "${ARG<N>}")`, after checking `ARGC`.
- There are no unparsed or unused arguments.
  Always check for `ARGN` or `arg_UNPARSED_ARGUMENTS`.
  `FATAL_ERROR` when possible, `WARNING` if necessary for backwards compatibility.
- All `cmake_parse_arguments` must use `PARSE_ARGV`.
- All `foreach` loops must use `IN LISTS` and `IN ITEMS`.
- The variables `${ARGV}` and `${ARGN}` are unreferenced,
  except in helpful messages to the user.
  - (i.e., `message(FATAL_ERROR "blah was passed extra arguments: ${ARGN}")`)
- We always use functions, not macros or top level code.
  - Exception: `vcpkg.cmake`'s `find_package`.
- Scripts in the scripts tree should not be expected to need changes
  as part of normal operation.
  - Example: `vcpkg_acquire_msys` has hard-coded packages and versions.
    We believe that this is unacceptable.
- All variable expansions are in quotes `""`,
  except those which are intended to be passed as multiple arguments.
  - Example:
  ```cmake
  set(working_directory)
  if(DEFINED arg_WORKING_DIRECTORY)
    set(working_directory "WORKING_DIRECTORY" "${arg_WORKING_DIRECTORY}")
  endif()
  # calls do_the_thing() if NOT DEFINED arg_WORKING_DIRECTORY,
  # else calls do_the_thing(WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}")
  do_the_thing(${working_directory})
  ```
- There are no "pointer" parameters
  (where a user passes a variable name rather than the contents)
  except for out parameters.
- Undefined names are not referenced.
- Out parameters are only set in `PARENT_SCOPE`.
- `CACHE` variables are not used.
  - Exception: internal global variables to avoid duplicating work.
- `include()`s are only allowed in `ports.cmake` or `vcpkg-port-config.cmake`.
- `foreach(RANGE)`'s arguments _must always be_ natural numbers,
  and `<start>` _must always be_ less than or equal to `<stop>`.
  - This must be checked if necessary.
- All port-based scripts must use `include_guard(GLOBAL)`
  to avoid being included multiple times.
- `set(VAR )` should not be used. Use `set(VAR)` to unset a variable.

### CMake Versions to Require

- All CMake scripts, except for `vcpkg.cmake`,
  may assume the version of CMake that is present in the
  `cmake_minimum_required` of `ports.cmake`.
  - This `cmake_minimum_required` should be bumped every time a new version
    of CMake is added to `vcpkgTools.xml`, as should the
    `cmake_minimum_required` in all of the helper `CMakeLists.txt` files.
- `vcpkg.cmake` must assume a version of CMake back to 3.1 in general
  - Specific functions and options may assume a greater CMake version;
    if they do, make sure to comment that function or option
    with the required CMake version.


### Changing Existing Functions

- Never remove arguments in non-internal functions;
  if they should no longer do anything, just take them as normal and warn on use.
- Never add a new mandatory argument.

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
