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
    vcpkg_build_qmake(${ARGN})
    file(GLOB_RECURSE RELEASE_LIBS
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.a
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.so
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.so.*
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dylib
    )
    file(GLOB_RECURSE RELEASE_BINS
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll
    )
    file(GLOB_RECURSE DEBUG_LIBS
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.a
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.so
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.so.*
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dylib
    )
    file(GLOB_RECURSE DEBUG_BINS
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll
    )
    if(NOT RELEASE_LIBS AND NOT DEBUG_LIBS)
        message(FATAL_ERROR "Build did not appear to produce any libraries. If this is intended, use `vcpkg_build_qmake()` directly.")
    endif()
    if(RELEASE_LIBS)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
        file(COPY ${RELEASE_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    endif()
    if(DEBUG_LIBS)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
        file(COPY ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif()
    if(RELEASE_BINS)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${RELEASE_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    if(DEBUG_BINS)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(COPY ${DEBUG_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endfunction()
