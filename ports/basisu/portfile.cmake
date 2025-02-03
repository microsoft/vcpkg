vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BinomialLLC/basis_universal
    REF "v1_50_0_2"
    SHA512 845077e9c88a3610b4845bbf4856a2141d678751eb2b5eba26bb4cbbaa0199ad4eae6a37dee485bfcac9d583ee6dca983f300fb7e2b86dfbc9824b5059e11345
    HEAD_REF master
    PATCHES
        # Remove once https://github.com/BinomialLLC/basis_universal/pull/383 merged
        0001-cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES "basisu" AUTO_CLEAN)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME basisu CONFIG_PATH lib/cmake/basisu)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
