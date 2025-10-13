vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hyperscan
    REF "v${VERSION}"
    SHA512 328f21133161d16b36ebdc7f8b80a7afe7ca9e7e7433348e9bfa9acb5f3641522e8314beea1b219891f4e95f1392ff8036ebb87780fe808b8b4bd15a535e9509
    HEAD_REF master
    PATCHES
        0001-remove-Werror.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
