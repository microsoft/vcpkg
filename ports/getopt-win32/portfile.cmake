vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaozhuai/getopt-win32
    REF b69a586f0b1aa37b77c3cf0a9dedba1900007678
    SHA512 6e52b6f198073e85b3a29a2fe21435c591fce02c68cb8cf9b546791dd1197e9b91dd9104af449071b4a1d1485817a483f1989a2e585c2d0470cfd079290fe155
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(COPY "${SOURCE_PATH}/getopt.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/getopt.h"
        "defined(STATIC_GETOPT)"
        "1"
    )
endif()

vcpkg_cmake_config_fixup(
    CONFIG_PATH  "share/unofficial-getopt-win32"
    PACKAGE_NAME "unofficial-getopt-win32"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS "enabled")
