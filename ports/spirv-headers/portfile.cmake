
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF sdk-1.3.231.1
    SHA512 d2c47127fd81430383e8656917f76933b713ca6cb93b2a9c16c9e0b125e2f62f8c497cab3a4fcc2a711decd911ec5d15f1eb0270add05442aff6672e08c890d7
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
