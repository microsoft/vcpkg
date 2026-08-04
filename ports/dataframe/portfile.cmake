vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF "${VERSION}"
    SHA512 fd83dbf51b8318e555cd73bd3dc36b4afe2023269266f7547c52d9842b9d5fb8942a27bf6fcbbc5571e4323e99a32553183106e09a1b68af1187a09fff717630
    HEAD_REF master
    PATCHES
        0001-correct-version.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHMDF_TESTING:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/DataFrame)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")
