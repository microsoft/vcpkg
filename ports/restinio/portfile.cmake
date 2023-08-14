vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF "v.${VERSION}"
    SHA512 8a535ebcdfb53ef9f669bbd007d11b6d95bae87b1a8b8403556910e4904483bfcaeb88fa2ee5522c9bef048a9276cbdb1fa15ec62b5bd158fc585b0e84cf046b
    PATCHES
        fix-cmake-config.diff
        fix-project.diff
)

set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/vcpkg"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
