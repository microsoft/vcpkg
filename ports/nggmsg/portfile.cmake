vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xhk/nggmsg
    REF version-20251208-2
    SHA512 384595ce38dc6834e3a12e4f59b8c49512fe4005f2db906329a3e42512ade1d64e68f428303a5892ad0fba94d29433bc6bd60c00a2224df22fcfb63971ebf385
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME nggmsg CONFIG_PATH share/nggmsg/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")