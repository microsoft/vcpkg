vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librsync/librsync
    REF 42b636d2a65ab6914ea7cac50886da28192aaf9b # V2.3.2
    SHA512 4903a64e327a7d49ae5f741b7b9fe3a76018010147249e2bc53917b06d31ee0f9b917f6c3e36a2d241ae66c19fa881113b59911d777742a859922486d9fe9c4c
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
