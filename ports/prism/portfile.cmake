vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ethindp/prism
    REF v0.3.4
    SHA512 10bbafd5cfd4561846efb9a7b4c7745418158852c33485a3a9c38dfca1e87a931b118f813bdcddf2ce94188c0e1fcc99315b2d7b1f38e7752c7b3b7f1e0b44ff
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPRISM_ENABLE_TESTS=OFF
        -DPRISM_ENABLE_DEMOS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME prism CONFIG_PATH share/prism)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")  # Add this line
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "Note: Speech Dispatcher must be installed on the host system (e.g., 'apt install libspeechd-dev').")
endif()
set(VCPKG_POLICY_SKIP_MISMATCHED_PDB_CHECK enabled)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
