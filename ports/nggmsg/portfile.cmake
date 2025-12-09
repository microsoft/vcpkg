vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xhk/nggmsg
    REF "${VERSION}"
    SHA512 384595ce38dc6834e3a12e4f59b8c49512fe4005f2db906329a3e42512ade1d64e68f428303a5892ad0fba94d29433bc6bd60c00a2224df22fcfb63971ebf385
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "my_sample_lib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")