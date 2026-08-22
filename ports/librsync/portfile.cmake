vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librsync/librsync
    REF "v${VERSION}"
    SHA512 ac01413b875e774db9fec3888210a4b9a5f3d32c081f1ed5f2cf9dc29cfae6ecedf6eac42062631e6dcf188853313fce4520430549768a0f68993419b07e58d9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_RDIFF:BOOL=OFF
        -DENABLE_COMPRESSION:BOOL=OFF
        -DENABLE_TRACE:BOOL=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/rsync.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/rsync.dll" "${CURRENT_PACKAGES_DIR}/bin/rsync.dll")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/rsync.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/rsync.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/rsync.dll")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/librsync_export.h"
        "#  ifdef LIBRSYNC_STATIC_DEFINE"
        "#  if 1 /* LIBRSYNC_STATIC_DEFINE */"
    )
endif()

vcpkg_copy_pdbs()
file(INSTALL  "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
