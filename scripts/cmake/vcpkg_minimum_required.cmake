#[===[.md:
# vcpkg_minimum_required

Asserts that the version of the vcpkg program being used to build a port is later than the supplied date, inclusive.

## Usage
```cmake
vcpkg_check_linkage(
    VERSION 2021-01-13
)
```

## Parameters
### VERSION
The date-version to check against.
#]===]

function(vcpkg_minimum_required)
    cmake_parse_arguments(PARSE_ARGV 0 _vcpkg "" "VERSION" "")
    if (NOT DEFINED VCPKG_BASE_VERSION)
        message(FATAL_ERROR
            "Your vcpkg executable is outdated and is not compatible with the current CMake scripts. "
            "Please re-acquire vcpkg by running bootstrap-vcpkg."
        )
    endif()

    string(REGEX MATCH "[12][0-9][0-9][0-9]-[01][0-9]-[0-2][0-9]" _vcpkg_matched_base_version "${VCPKG_BASE_VERSION}")
    if (NOT _vcpkg_matched_base_version STREQUAL VCPKG_BASE_VERSION)
        message(FATAL_ERROR
            "vcpkg internal failure; \${VCPKG_BASE_VERSION} (${VCPKG_BASE_VERSION}) was not a valid date."
            )
    endif()

    string(REPLACE "-" "." _VCPKG_BASE_VERSION_as_dotted "${_vcpkg_matched_base_version}")

    string(REGEX MATCH "[12][0-9][0-9][0-9]-[01][0-9]-[0-2][0-9]" _vcpkg_matched_test_version "${_vcpkg_VERSION}")
    if (NOT _vcpkg_matched_test_version STREQUAL _vcpkg_VERSION)
        message(FATAL_ERROR
            "VERSION parameter to vcpkg_minimum_required was not a valid date. "
            "Comparing with vcpkg tool version ${_vcpkg_matched_base_version}"
            )
    endif()

    string(REPLACE "-" "." _vcpkg_test_version_as_dotted "${_vcpkg_matched_test_version}")

    if (_VCPKG_BASE_VERSION_as_dotted VERSION_LESS _vcpkg_test_version_as_dotted)
        message(FATAL_ERROR
            "Your vcpkg executable is from ${_vcpkg_matched_base_version} which is older than required by the caller "
            "of vcpkg_minimum_required (${_vcpkg_matched_test_version}). "
            "Please re-acquire vcpkg by running bootstrap-vcpkg."
        )
    endif()
endfunction()
