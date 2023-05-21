vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spnda/fastgltf
    REF "v${VERSION}"
    SHA512 721ea38c0461b8d038c008cc7c8990dc48b1d0fe038edc764439551e7b22c5dce1a12655b2d3c9a9c6d10a3876e61aefc29571e359c4db6500416ed7a81fb65a
    HEAD_REF main
    PATCHES find_package.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DFASTGLTF_DOWNLOAD_SIMDJSON=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
