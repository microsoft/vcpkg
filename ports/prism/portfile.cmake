vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ethindp/prism
    REF v0.4.1
    SHA512 9058623b6f5a236ffdc4ce3ca42aab341b834250cfac37a39d8fb35854a5ad2a0fa0b97b8346fe3a9613f5e5e0d9117c0e81ecc346f2fcd96c3e1d23a7f2403f
    HEAD_REF master
)
if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "Note: Speech Dispatcher must be installed on the host system (e.g., 'apt install libspeechd-dev') to enable the speech dispatcher backend.")
endif()
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
set(VCPKG_POLICY_SKIP_MISMATCHED_PDB_CHECK enabled)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
