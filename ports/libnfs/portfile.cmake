vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://github.com/sahlberg/libnfs.git"
    REF 5b1bc60260b5ddac34900c5315010b88b73e7edd
    FETCH_REF "refs/tags/libnfs-${VERSION}"
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

if(VCPKG_TARGET_IS_IOS)
    list(APPEND GSSAPI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GSSAPI=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Upstream utilities/examples are GPL-3.0-or-later. Keep this port library-only.
        ${FEATURE_OPTIONS}
        ${GSSAPI_OPTIONS}
        -DENABLE_TESTS=OFF
        -DENABLE_DOCUMENTATION=OFF
        -DENABLE_UTILS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_NFS4_2=ON
        -DENABLE_TLS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME libnfs
    CONFIG_PATH lib/cmake/libnfs
)

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
