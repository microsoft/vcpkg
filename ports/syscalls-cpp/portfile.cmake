vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sapdragon/syscalls-cpp
    REF "${VERSION}"            
    SHA512 758edab3e4d691b06398e26f568cf4ee5c2ea35921fd77ba2375f3c31502890075f635cf60493ac0fb118ddb954902143500bddfbf0fac6020c5433e55e05a43
    HEAD_REF main                
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSYSCALL_CPP_BUILD_EXAMPLES=OFF
        -DSYSCALL_CPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
