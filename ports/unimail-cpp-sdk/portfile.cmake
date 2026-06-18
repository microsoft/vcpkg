vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unimails/unimail-cpp-sdk
    REF "v${VERSION}"
    SHA512 92820373dd161d0c7c04cd170555eb63e7d22b908f9557f197028b2032221fcb679d5e9275843d1cbfb27dbe83d985b84a0c8b5550a0b8077d7eee829838d964
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNIMAIL_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/unimail-cpp-sdk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
