vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF "v${VERSION}"
    SHA512 97d7a2892af67adad16b6ff0fb3e6324c88d1dd931dfa0d34cf6d181baec05ed791f0980abf2174db22aabaa382fd5b5f00cb287cf6477a4786c999f29719717
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPYBIND11_TEST=OFF
        # Disable all Python searching, Python required only for tests
        -DPYBIND11_NOPYTHON=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/pybind11")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
