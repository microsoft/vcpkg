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

- Except for out-parameters, we always use `cmake_parse_arguments()`
  rather than function parameters or referring to `${ARG<N>}`.
  - This doesn't necessarily need to be followed for "script-local helper functions"
    - In this case, positional parameters should be put in the function
      declaration (rather than using `${ARG<N>}`),
      and should be named according to local rules (i.e. `snake_case`).
    - Exception: positional parameters that are optional should be
      given a name via `set(argument_name "${ARG<N>}")`, after checking `ARGC`.
  - Out-parameters should be the first parameter to a function. Example:
  ```cmake
  function(format out_var)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" ...)
    # ... set(buffer "output")
    set("${out_var}" "${buffer}" PARENT_SCOPE)
  endfunction()
  ```
- There are no unparsed or unused arguments.
  Always check for `ARGN` or `arg_UNPARSED_ARGUMENTS`.
  `FATAL_ERROR` when possible, `WARNING` if necessary for backwards compatibility.
- All `cmake_parse_arguments` must use `PARSE_ARGV`.
- All `foreach` loops must use `IN LISTS`, `IN ITEMS`, or `RANGE`.
- The variables `${ARGV}` and `${ARGN}` are unreferenced,
  except in helpful messages to the user.
  - (i.e., `message(FATAL_ERROR "blah was passed extra arguments: ${ARGN}")`)
- We always use functions, not macros or top level code.
  - Exception: "script-local helper macros". It is sometimes helpful to define a small macro.
    This should be done sparingly, and functions should be preferred.
  - Exception: `vcpkg.cmake`'s `find_package`.
- Scripts in the scripts tree should not be expected to need observable changes
  as part of normal operation.
  - Example violation: `vcpkg_acquire_msys()` has hard-coded packages and versions
    that need updating over time due to the MSYS project dropping old packages.
  - Example exception: `vcpkg_from_sourceforge()` has a list of mirrors which
    needs maintenance, but does not have an observable behavior impact on the callers.
- Rules for quoting: there are three kinds of arguments in CMake -
  unquoted (`foo(BAR)`), quoted (`foo("BAR")`), and bracketed (`foo([[BAR]])`).
  Follow these rules to quote correctly:
  - If an argument contains a variable expansion `${...}`,
    it must be quoted.
    - Exception: a "splat" variable expansion, when one variable will be
      passed to a function as multiple arguments. In this case, the argument
      should simply be `${foo}`:
      ```cmake
      vcpkg_list(SET working_directory)
      if(DEFINED "arg_WORKING_DIRECTORY")
        vcpkg_list(SET working_directory WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}")
      endif()
      # calls do_the_thing() if NOT DEFINED arg_WORKING_DIRECTORY,
      # else calls do_the_thing(WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}")
      do_the_thing(${working_directory})
      ```
  - Otherwise, if the argument contains any escape sequences that are not
    `\\`, `\"`, or `\$`, that argument must be a quoted argument.
    - For example: `"foo\nbar"` must be quoted.
  - Otherwise, if the argument contains a `\`, a `"`, or a `$`,
    that argument should be bracketed.
    - Example:
      ```cmake
      set(x [[foo\bar]])
      set(y [=[foo([[bar\baz]])]=])
      ```
  - Otherwise, if the argument contains characters that are
    not alphanumeric or `_`, that argument should be quoted.
  - Otherwise, the argument should be unquoted.
  - Exception: arguments to `if()` of type `<variable|string>` should always be quoted:
    - Both arguments to the comparison operators -
      `EQUAL`, `STREQUAL`, `VERSION_LESS`, etc.
    - The first argument to `MATCHES` and `IN_LIST`
    - Example:
      ```cmake
      if("${FOO}" STREQUAL "BAR") # ...
      if("${BAZ}" EQUAL "0") # ...
      if("FOO" IN_LIST list_variable) # ...
      if("${bar}" MATCHES [[a[bcd]+\.[bcd]+]]) # ...
      ```
    - For single expressions and for other types of predicates that do not
    take `<variable|string>`, use the normal rules.
- There are no "pointer" or "in-out" parameters
  (where a user passes a variable name rather than the contents),
  except for simple out-parameters.
- Variables are not assumed to be empty.
  If the variable is intended to be used locally,
  it must be explicitly initialized to empty with `set(foo "")` if it is a string variable,
  and `vcpkg_list(SET foo)` if it is a list variable.
- `set(var)` should not be used. Use `unset(var)` to unset a variable,
  `set(var "")` to set it to the empty string,
  and `vcpkg_list(SET var)` to set it to the empty list.
  _Note: the empty string and the empty list are the same value;_
  _this is a notational difference rather than a difference in result_
- All variables expected to be inherited from the parent scope across an API boundary
  (i.e. not a file-local function) should be documented.
  Note that all variables mentioned in triplets.md are considered documented.
- Out parameters are only set in `PARENT_SCOPE` and are never read.
  See also the helper `z_vcpkg_forward_output_variable()` to forward out parameters through a function scope.
- `CACHE` variables are used only for global variables which are shared internally among strongly coupled
  functions and for internal state within a single function to avoid duplicating work.
  These should be used extremely sparingly and should use the `Z_VCPKG_` prefix to avoid
  colliding with any local variables that would be defined by any other code.
  - Examples:
    - `vcpkg_cmake_configure`'s `Z_VCPKG_CMAKE_GENERATOR`
    - `z_vcpkg_get_cmake_vars`'s `Z_VCPKG_GET_CMAKE_VARS_FILE`
- `include()`s are only allowed in `ports.cmake` or `vcpkg-port-config.cmake`.
- `foreach(RANGE)`'s arguments _must always be_ natural numbers,
  and `<start>` _must always be_ less than or equal to `<stop>`.
  - This must be checked by something like:
  ```cmake
  if("${start}" LESS_EQUAL "${end}")
    foreach(RANGE "${start}" "${end}")
      ...
    endforeach()
  endif()
  ```
- All port-based scripts must use `include_guard(GLOBAL)`
  to avoid being included multiple times.

### CMake Versions to Require

- All CMake scripts, except for `vcpkg.cmake`,
  may assume the version of CMake that is present in the
  `cmake_minimum_required` of `ports.cmake`.
  - This `cmake_minimum_required` should be bumped every time a new version
    of CMake is added to `vcpkgTools.xml`, as should the
    `cmake_minimum_required` in all of the helper `CMakeLists.txt` files.
- `vcpkg.cmake` must assume a version of CMake back to 3.7.2 in general
  - Specific functions and options may assume a greater CMake version;
    if they do, make sure to comment that function or option
    with the required CMake version.


### Changing Existing Functions

- Never remove arguments in non-internal functions;
  if they should no longer do anything, just take them as normal and warn on use.
- Never add a new mandatory argument.

### Naming Variables

- `cmake_parse_arguments`: set prefix to `"arg"`
- Local variables are named with `snake_case`
- Internal global variable names are prefixed with `Z_VCPKG_`.
- External experimental global variable names are prefixed with `X_VCPKG_`.

- Internal functions are prefixed with `z_vcpkg_`
  - Functions which are internal to a single function (i.e., helper functions)
    are named `[z_]<func>_<name>`, where `<func>` is the name of the function they are
    a helper to, and `<name>` is what the helper function does.
    - `z_` should be added to the front if `<func>` doesn't have a `z_`,
      but don't name a helper function `z_z_foo_bar`.
- Public global variables are named `VCPKG_`.
