vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sahlberg/libnfs
    REF "libnfs-${VERSION}"
    SHA512 29a07c5fbba638738eb9b5443f4d1be0c424b8a5bf6982c40fb791123cbefdd930fff0b04d5debb21151991168f3ebaebab6e7f03bc1c64013e62040bb6a55f4
    HEAD_REF master
    PATCHES
        fix-cmake-target-interface.patch
        fix-android-pthread-detection.patch
        fix-win32-header-detection.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        multithreading ENABLE_MULTITHREADING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Upstream utilities/examples are GPL-3.0-or-later. Keep this port library-only.
        ${FEATURE_OPTIONS}
        -DENABLE_TESTS=OFF
        -DENABLE_DOCUMENTATION=OFF
        -DENABLE_UTILS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_NFS4_2=ON
        -DENABLE_TLS=OFF
        -DENABLE_KRB5=OFF
        -DENABLE_RDMA=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME libnfs
    CONFIG_PATH lib/cmake/libnfs
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(NOT VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libnfs.pc" "-lnfs" "-llibnfs")
    endif()
    if(NOT VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libnfs.pc" "-lnfs" "-llibnfs")
    endif()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/LICENCE-LGPL-2.1.txt"
        "${SOURCE_PATH}/LICENCE-BSD.txt"
        "${SOURCE_PATH}/include/win32/win32_compat.h"
)
