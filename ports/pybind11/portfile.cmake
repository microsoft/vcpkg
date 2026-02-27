vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF "v${VERSION}"
    SHA512 19bee2c76320e25202ee078b5680ff8a7acfb33494dec29dad984ab04de8bcb01340d9fec37c8cc5ac9015dfc367e60312dcd8506e66ce8f0af4c49db562ddef
    HEAD_REF master
    PATCHES
        android.diff
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
