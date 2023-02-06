vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wadehunk/open-dis-cpp
    REF 6145d31a11ad6effc215a517f0aa19ef7128828d
    SHA512 61676d3dc459afe240ece6a47e848337bc332e945f961a6e64ad69446a9120feccd3ec0ba11ef4368908d72daa6a7f202e604e9314b3c91db28240da2d7eed1e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME OpenDIS CONFIG_PATH lib/cmake/OpenDIS)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
