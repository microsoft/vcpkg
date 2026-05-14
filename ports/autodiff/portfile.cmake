vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO autodiff/autodiff
    REF "v${VERSION}"
    SHA512 a8f3c3126fc8fb9502384eaf6cb416bfb24dede83edc70a8333c9e2824fefcb4221da71d2f0b30b52dcbe86042cb79a9dd1d93249bfdb052af71c0c1c63c819e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAUTODIFF_BUILD_TESTS=OFF
        -DAUTODIFF_BUILD_PYTHON=OFF
        -DAUTODIFF_BUILD_EXAMPLES=OFF
        -DAUTODIFF_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/autodiff)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
