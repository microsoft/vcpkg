vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO free-audio/clap
    REF "${VERSION}"
    SHA512 5637edee7e9d63b7c7eafd0a9f25e6ed4e3670412802578ef1749cde4d16d63ec3f776e233a847b747a8db2e23ae4c6c3eeac84fb18d14f93a47cdf9a11e346b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/clap")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
