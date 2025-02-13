vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://github.com/ooraloo/hdbscan-cpp-vcpkg"
    REF "382c494ecdda557a9a1bf5e0d700d45b9e8decf7"
    FETCH_REF "master"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.md)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")