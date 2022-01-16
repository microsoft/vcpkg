#[===[.md:
# vcpkg_cmake_validate

Test the correctness of the cmake package information established by a find_package() call.

```cmake
vcpkg_cmake_validate(
    [CMAKE_MINIMUM_VERSION <version>]
    [CMAKE_PROLOGUE <cmake statements>...]
    FIND_PACKAGE <Pkg> <find_package arguments>...
    [LIBRARIES <targets or variable names>...]
    [HEADERS <headername.h>...]
    [FUNCTIONS <function1> ...]
)
```

`vcpkg_cmake_validate` configures a CMake build system in order to test that
`find_package(<Pkg> ...)` provides variables and targets as expected.
In particular, it checks that:
 - `<Pkg>_FOUND` or `<PKG>_FOUND`  is defined and true,
 - libraries and include paths are either defined via variables, or 
   libraries are targets which are assumed to carry usage requirements such
   as include paths.

If given headers and functions, it will also generate a C++ source file and
build the test project in order to verify compilation and linking steps.

These tests may take some time, and they also depend on the version of CMake.
To avoid impact on normal users, the test must be explicitly enabled via port
`vcpkg-maintainer-options`:
  - `vcpkg-maintainer-options[minimum-cmake]` enables testing with the minimum
    version of CMake which is available for the current host and compatible with
    the test.
  - `vcpkg-maintainer-options[current-cmake]` enables testing with the current
    version of CMake, possibly in addition to the minimum version if both
    features are installed. This feature simply uses the same CMake binary as
    vcpkg does.

## Parameters
### CMAKE_MINIMUM_VERSION

The minimum version of CMake which is required for this test.
The test can also be executed with a higher version. If this parameter is missing,
the test will be executed with all versions enabled for testing.

This argument does not affect the active policies.
Use `CMAKE_PROLOGUE` if a test needs certain policies to be enabled.

### CMAKE_PROLOGUE

Additional CMake statements to be added before the `project()` command.

### FIND_PACKAGE

Arguments to pass to the `find_package` command. This parameter is required.
The first argument is the canonical package name ("`<Pkg>`").

### LIBRARIES

Names of variables or targets that shall be checked for existence after `find_package()`.
Variable names must be given without `${` and `}`. The test project inspects the build
system to find out whether the identifier names a defined variable or target.

The test also expands the list of libraries to be linked, including transitive usage
requirements, and checks if libraries located in the vcpkg installed tree match the
build type of the test project.

### HEADERS

Header files to be included in the test source file.
The headers must provide the symbols used by the `FUNCTIONS` parameter.

### FUNCTIONS

Function names to be referenced in the test source file.
These names are to provided by the linked libraries.

## Examples

* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
* [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/openssl.cmake)
#]===]
if(COMMAND vcpkg_cmake_validate)
    return()
endif()

function(vcpkg_cmake_validate)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "CMAKE_MINIMUM_VERSION"
        "CMAKE_PROLOGUE;FIND_PACKAGE;LIBRARIES;HEADERS;FUNCTIONS"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_validate was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT arg_FIND_PACKAGE)
        message(FATAL_ERROR "vcpkg_cmake_validate must be passed 'FIND_PACKAGE <Pkg> ...' arguments.")
    endif()
    if(NOT arg_CMAKE_MINIMUM_VERSION)
        set(arg_CMAKE_MINIMUM_VERSION "2.4")
    endif()

    # Help identify repeated similar calls to vcpkg_cmake_validate.
    set(counter_var "Z_VCPKG_CMAKE_VALIDATE_BUILD")
    if(DEFINED Z_VCPKG_CMAKE_VALIDATE_BUILD)
        math(EXPR count "${Z_VCPKG_CMAKE_VALIDATE_BUILD} + 1")
    else()
        set(count 1)
    endif()
    set(Z_VCPKG_CMAKE_VALIDATE_BUILD "${count}" CACHE INTERNAL "")

    # Testing can be enabled by files which are normally installed via features
    # of port vcpkg-maintainer-options. There is no hard dependency.
    # For `vcpkg ci` scenarios, the files may be copied manually in advance.
    set(options_enabled "${CURRENT_INSTALLED_DIR}/share/vcpkg-maintainer-options/enabled")
    include("${options_enabled}/current-cmake.cmake" OPTIONAL RESULT_VARIABLE enable_current_cmake)
    include("${options_enabled}/minimum-cmake.cmake" OPTIONAL RESULT_VARIABLE enable_minimum_cmake)
    vcpkg_list(SET cmake_versions)
    if(enable_minimum_cmake)
        vcpkg_maintainer_options_minimum_cmake(OUT_VAR minimum_cmake VERSION "${arg_CMAKE_MINIMUM_VERSION}")
        vcpkg_list(APPEND cmake_versions "${minimum_cmake}")
    endif()
    if(enable_current_cmake AND NOT cmake_versions MATCHES ";${CMAKE_VERSION}$")
        set(current_cmake "${CMAKE_COMMAND}" VERSION "${CMAKE_VERSION}")
        vcpkg_list(APPEND cmake_versions "${current_cmake}")
    endif()

    if(NOT cmake_versions)
        if(NOT count)
            message(STATUS "`find_package` validation is disabled. Use port vcpkg-maintainer-options to enable tests.")
        endif()
        return()
    endif()

    if(DEFINED ENV{VCPKG_FORCE_SYSTEM_BINARIES})
        find_program(NINJA ninja)
    else()
        vcpkg_find_acquire_program(NINJA)
    endif()

    set(label "`find_package(${arg_FIND_PACKAGE})`")
    if(arg_LIBRARIES)
        string(APPEND label ", libraries: ${arg_LIBRARIES}")
    endif()
    list(JOIN label " " label)

    string(REGEX REPLACE "[^;]*.VERSION.." "" display_versions "${cmake_versions}")
    list(JOIN display_versions "+" display_versions)
    message(STATUS "(${count}) Validating ${label}, CMake ${display_versions}")

    foreach(cmake IN LISTS cmake_versions)
        z_vcpkg_cmake_validate_build(
            COUNT "${count}"
            LABEL "${label}"
            CMAKE ${cmake}
            CMAKE_PROLOGUE ${arg_CMAKE_PROLOGUE}
            FIND_PACKAGE ${arg_FIND_PACKAGE}
            LIBRARIES ${arg_LIBRARIES}
            HEADERS   ${arg_HEADERS}
            FUNCTIONS ${arg_FUNCTIONS}
        )
    endforeach()
endfunction()
