vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/expected
    REF b74fecd4448a1a5549402d17ddc51e39faa5020c # 2022-11-24
    SHA512 d59d7a63dc0f7244cd0a65971ed2b51e2d01de8658b043673aacb83c7bcefb90009f2d5792a49943c9d5e80f9f5811f5db3db1bb11f8429c9e732c872b91ae66
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEXPECTED_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tl-expected)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cmake")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
