#[===[.md:
# vcpkg_minimum_required

Asserts that the version of the vcpkg program being used to build a port is later than the supplied date, inclusive.

## Usage
```cmake
vcpkg_minimum_required(VERSION 2021-01-13)
```

## Parameters
### VERSION
The date-version to check against.
#]===]

function(vcpkg_minimum_required)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "VERSION" "")
    if (NOT DEFINED VCPKG_BASE_VERSION)
        message(FATAL_ERROR
            "Your vcpkg executable is outdated and is not compatible with the current CMake scripts. "
            "Please re-acquire vcpkg by running bootstrap-vcpkg."
        )
    endif()

    set(vcpkg_date_regex "^[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]$")
    if (NOT VCPKG_BASE_VERSION MATCHES "${vcpkg_date_regex}")
        message(FATAL_ERROR
            "vcpkg internal failure; VCPKG_BASE_VERSION (${VCPKG_BASE_VERSION}) was not a valid date."
            )
    endif()

    if (NOT arg_VERSION MATCHES "${vcpkg_date_regex}")
        message(FATAL_ERROR
            "VERSION parameter to vcpkg_minimum_required was not a valid date. "
            "Comparing with vcpkg tool version ${VCPKG_BASE_VERSION}"
            )
    endif()

    string(REPLACE "-" "." VCPKG_BASE_VERSION_as_dotted "${VCPKG_BASE_VERSION}")
    string(REPLACE "-" "." arg_VERSION_as_dotted "${arg_VERSION}")

    if (VCPKG_BASE_VERSION_as_dotted VERSION_LESS vcpkg_VERSION_as_dotted)
        message(FATAL_ERROR
            "Your vcpkg executable is from ${VCPKG_BASE_VERSION} which is older than required by the caller "
            "of vcpkg_minimum_required(VERSION ${arg_VERSION}). "
            "Please re-acquire vcpkg by running bootstrap-vcpkg."
        )
    endif()
endfunction()
