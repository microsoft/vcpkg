vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Roblox/luau
    REF "${VERSION}"

    SHA512 883e18ef93784f5625339b6b37c02cd0dc5dbc9063c4b622380b660b5e0df41f89c6062f64ef44c1f7b0e8f4a275552e363a50cedebea2bbe14943de29fb5e5c
    HEAD_REF master
    PATCHES
        cmake-install.patch
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
