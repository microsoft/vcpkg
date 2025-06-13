vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libplist
    REF ${VERSION}
    SHA512 0477202686fb2f88684af30a97d53fd023ada470dfc7c5d8b32c0d80e09a4641e679522a53c5ad32eae61b21a2d0f1f0c660acd8482ba7951d728b42e4cf5eab
    HEAD_REF master
    PATCHES
        001_fix_static_build.patch
)

set(options "")
if("tools" IN_LIST FEATURES)
    list(APPEND options --with-tools=yes)
else()
    list(APPEND options --with-tools=no)
endif()

set(ENV{RELEASE_VERSION} "${VERSION}")
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${options}
        --without-cython
)
file(COPY_FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libtool" "${CURRENT_BUILDTREES_DIR}/libtool.log")
file(COPY_FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Makefile" "${CURRENT_BUILDTREES_DIR}/Makefile.log")
file(COPY_FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libcnary/Makefile" "${CURRENT_BUILDTREES_DIR}/Makefile-libcnary.log")
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plist/plist.h"
        "#ifdef LIBPLIST_STATIC" "#if 1"
    )
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plist/plist.h"
        "#ifdef LIBPLIST_STATIC" "#if 0"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-${PORT}-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
