vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Naios/function2
    REF "${VERSION}"
    SHA512 a70cc4d5cdcd9a108c930ef6f18662f649405b2c6d0c0e25526af555392503f467bfa7755d0f00651ad61c339102315cc2a1c9354326433bfaa3f8110517a79c
    HEAD_REF master
    PATCHES
        disable-testing.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/Readme.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
