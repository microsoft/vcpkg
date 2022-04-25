#[===[.md:
# vcpkg_requires_compiler_flags

Runs a cmake configure with a dummy project to check the required items

## Usage
```cmake
vcpkg_requires_compiler_flags(
    C_STANDARD <standard>
    CXX_STANDARD <standard>
)
```

#]===]

set(Z_VCPKG_REQUIRES_COMPILER_FLAGS_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(vcpkg_requires_compiler_flags)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "C_STANDARD;CXX_STANDARD" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    
    vcpkg_list(SET requires_flags)
    if (arg_C_STANDARD)
        vcpkg_list(APPEND requires_flags "-DC_STANDARD=${arg_C_STANDARD}")
    endif()
    
    if (arg_CXX_STANDARD)
        vcpkg_list(APPEND requires_flags "-DCXX_STANDARD=${arg_CXX_STANDARD}")
    endif()

    if(NOT DEFINED CACHE{Z_VCPKG_REQUIRES_COMPILER_FLAGS_FILE})
        set(Z_VCPKG_REQUIRES_COMPILER_FLAGS_FILE "${CURRENT_BUILDTREES_DIR}/requires-compiler-flags-${TARGET_TRIPLET}.cmake.log"
            CACHE PATH "The file to include to access the CMake variables from a generated project.")
        vcpkg_cmake_configure(
            SOURCE_PATH "${Z_VCPKG_REQUIRES_COMPILER_FLAGS_CURRENT_LIST_DIR}/requires_compiler_flags"
            OPTIONS ${requires_flags}
            OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/requires-compiler-flags-${TARGET_TRIPLET}-dbg.cmake.log"
            OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/requires-compiler-flags-${TARGET_TRIPLET}-rel.cmake.log"
            LOGFILE_BASE requires-compiler-flags-${TARGET_TRIPLET}
            Z_CMAKE_GET_VARS_USAGE # be quiet, don't set variables...
        )

        set(include_string "")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/requires-compiler-flags-${TARGET_TRIPLET}-rel.cmake.log\")\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/requires-compiler-flags-${TARGET_TRIPLET}-dbg.cmake.log\")\n")
        endif()
        file(WRITE "${Z_VCPKG_REQUIRES_COMPILER_FLAGS_FILE}" "${include_string}")
    endif()

endfunction()
