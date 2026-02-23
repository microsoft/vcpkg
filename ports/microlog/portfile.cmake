vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-dr/microlog
    REF "v7.0.2"
    SHA512 4b4d4fade8bc264f862c8bfbdab6c9cccbb0a9a9727e05e65ed300829b98a608f57014372e9010fae01287a11a93a9a5bc4833b02661029fa938c48fb67766f3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/microlog")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
