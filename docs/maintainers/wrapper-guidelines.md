# Wrappers for CMake find modules

The vcpkg CMake toolchain modifies CMake's `find_package` behaviour by allowing
ports to provide wrappers for genuine CMake find modules. Wrappers do not
replace the original behaviour of find modules but help initializing variables
and targets with vcpkg port configuration details such as installation paths,
file names and transitive usage requirements related to active port features.

The original parameters passed to the `find_package` called are made available
to the wrapper in variable `ARGS`. The genuine find module can be called via
`_find_package`. The typical structure of a wrapper is the following:

```cmake
# Early setup: cache variables for library directories etc.
# (Goal: Make genuine module succeed with consistent configuration.)
...
# Call the genuine CMake find module.
_find_package(${ARGS})
# Late setup: complementary configuration for transitive usage requirements etc.
# (Goal: Improve usability and maintainability for vcpkg.)
...
```


## Wrapper naming and location

CMake's find module names (aka package names) are case sensitive. However, the
install location of a wrapper uses lower-case spelling of the package name for
the install location. On calling `find_package(<Pkg>)`, vcpkg will look for
`share/<pkg>/vcpkg-cmake-wrapper.cmake`.


## CMake version and policies

Wrappers cannot rely on a recent version of CMake. Unlike portfiles, wrappers
can run in the context of a user project where the version of CMake is determined
by the user. In order to not limit the usability of vcpkg, wrappers must not use
language features of CMake newer than version 3.4 unless really necessary.

Note that some language features depend not only the actual CMake version but
also on the activated policies. The default configuration is defined by the user
project's `cmake_minimum_required` statement. To use some features of CMake 3.4,
such as `if ("word" IN_LIST <list>)`, some policies must be activate locally:

```cmake
cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW)
...
cmake_policy(POP)
```


## Scoping of variables and targets

Find modules don't establish an own scope but operate in the scope of the
subdirectory where they are used. Some care is needed in order to avoid
interference with user projects and CMake behaviour.

- If a wrapper needs to create variables, these variables shall be prefixed
  with `Z_VCPKG`. They must not be used without initialization.
- If a wrapper creates CMake targets, these targets shall be namespaced by
  using prefix `unofficial::`.
- CMake macro `find_dependency` from module `CMakeFindDependencyMacro` cannot
  be used.


## Library locations and selection

Regular CMake find modules use `find_library(<Pkg>_LIBRARY_RELEASE ...)` and
`find_library(<Pkg>_LIBRARY_DEBUG ...)` to locate the link libraries for a
given `<Pkg>`. If the module fails to locate the proper release and debug
variants on its own, the usual wrapper pattern for early setup is:

```cmake
find_library(<Pkg>_LIBRARY_DEBUG NAMES name1d name2_d NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
find_library(<Pkg>_LIBRARY_RELEASE NAMES name1 name2 NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
```

If not implemented in the find module, the wrapper must take care of selecting
the right configuration for the `<Pkg>_LIBRARIES` variable. Remember that this
depends on the behaviour of the find module in the lowest supported version of
CMake.

```cmake
include(SelectLibraryConfigurations)
select_library_configurations(<Pkg>)
unset(<Pkg>_FOUND)  # https://gitlab.kitware.com/cmake/cmake/-/issues/22509
```


## Setting up targets

Wrappers may add extra targets which are not provided by a particular version
of a genuine find module. But find modules may be called multiple times, from
different subdirectories, in a user project. There are some pitfalls which must
be avoided:

- Before adding an imported target, always check if it already exists.
- Calling `target_link_libraries` on an imported target is only allowed in the
  subdirectory which created the target, for CMake versions lower than 3.21.
  (CMP0079/CMake 3.13 lifts the restriction for normal targets only.) 
  For simplicity, set/append the properties directly, e.g.
  
  ```cmake
  set_properties(TARGET <Pkg>::Tgt APPEND PROPERTIES INTERFACE_LINK_LIBRARIES some::lib)
  ```


## Handling port features

Vcpkg port features often result in transitive usage requirements which must
be added to variables and targets in late setup. The transfer of the list of
active features from port build time (portfile variable `FEATURES`) to wrapper
usage time must be done by a configuration step in `portfile.cmake`:

```cmake
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/<pkg>/vcpkg-cmake-wrapper.cmake"
    @ONLY
)
```

To capture the features in the installed wrapper, `vcpkg-cmake-wrapper.cmake.in`
must contain a line like:

```cmake
set(Z_VCPKG_FEATURES "@FEATURES@")
```

After this (and with policy CMP0057 activated) the port file may now inspect
the features and adjust the `_find_package` results accordingly:

```cmake
if("zlib" IN_LIST Z_VCPKG_FEATURES)
    find_package(ZLIB)
    list(APPEND <Pkg>_LIBRARIES ${ZLIB_LIBRARIES})
    if(TARGET <Pkg>::Tgt)
        set_property(TARGET <Pkg>::Tgt APPEND PROPERTY INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
    endif()
endif()
```


## Enforce loading of exported config files

If a port exports config files which provide accurate information as expected
by users of the find module, wrappers may enforce the loading of the config
files by adjusting the argument list:

```cmake
list(REMOVE_ITEM ARGS "NO_MODULE")
list(REMOVE_ITEM ARGS "CONFIG")
list(REMOVE_ITEM ARGS "MODULE")
_find_package(${ARGS} CONFIG)
```


## Handling the `REQUIRED` keyword

When `find_package` is called with the `REQUIRED` keyword (i.e. `REQUIRED`
occurs in list `ARGS`), any error in setting up the configuration and transitive
usage requirements may immediately raise a fatal error.

However, a normal call to `find_package` without passing the `REQUIRED` keyword
must not cause fatal CMake errors. It can indicate failure only by setting
`<Pkg>_FOUND` to `FALSE`. This implies that a wrapper must not use the
`REQUIRED` keyword when looking for transitive usage requirements via additional
calls to `find_package`.

(Normally, failures to find transitive usage requirements indicate serious
issues with the vcpkg setup. However, users may explicitly disable finding and
using some modules by setting `CMAKE_DISABLE_FIND_PACKAGE_<Pkg>` to `ON`.)
