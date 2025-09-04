vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zrax/string_theory
    REF "${VERSION}"
    SHA512 a36825ab22be64c7c7b54861e88dea0bde5f0b80d32fc86b863e4409c820a25fea17cfbf2d068c1fdf4fb371714337dff390d31c983ea898fbdc37a09c469b4a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DST_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME string_theory CONFIG_PATH lib/cmake/string_theory)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
