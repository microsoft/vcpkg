#[===[.md:
# vcpkg_install_qmake

Build and install a qmake project.

## Usage:
```cmake
vcpkg_install_qmake(...)
```

## Parameters:
See [`vcpkg_build_qmake()`](vcpkg_build_qmake.md).

## Notes:
This command transparently forwards to [`vcpkg_build_qmake()`](vcpkg_build_qmake.md).

Additionally, this command will copy produced .libs/.dlls/.as/.dylibs/.sos to the appropriate
staging directories.

## Examples

* [libqglviewer](https://github.com/Microsoft/vcpkg/blob/master/ports/libqglviewer/portfile.cmake)
#]===]

function(vcpkg_install_qmake)
    z_vcpkg_function_arguments(args)

    vcpkg_build_qmake(${args})

    file(GLOB_RECURSE release_libs
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.so"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.so.*"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dylib"
    )
    file(GLOB_RECURSE release_bins
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll"
    )
    file(GLOB_RECURSE debug_libs
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.so"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.so.*"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dylib"
    )
    file(GLOB_RECURSE debug_bins
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
    )
    if("${release_libs}" STREQUAL "" AND "${debug_libs}" STREQUAL "")
        message(FATAL_ERROR "Build did not appear to produce any libraries. If this is intended, use `vcpkg_build_qmake()` directly.")
    endif()
    if(NOT "${release_libs}" STREQUAL "")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
        file(COPY ${release_libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()
    if(NOT "${debug_libs}" STREQUAL "")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(COPY ${debug_libs} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
    if(NOT "${release_bins}" STREQUAL "")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
        file(COPY ${release_bins} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    endif()
    if(NOT "${debug_bins}" STREQUAL "")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY ${debug_bins} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endfunction()
