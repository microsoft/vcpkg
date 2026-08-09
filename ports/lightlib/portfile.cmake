vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lev2p1/lightlib
    REF v0.1.3
    SHA512 01412b7e26ae7f26664086b2f38ebec03d7c2a91831778819942e04f13b7135ebf6a55ad4b087ca74a3403dce1f813d9128a0c9fada5a173fbf71fa10aa1f3ba
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Light"
    GENERATOR "Visual Studio 18 2026"
    OPTIONS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

vcpkg_cmake_config_fixup(CONFIG_PATH share/lightlib)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")