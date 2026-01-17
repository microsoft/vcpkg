vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ethindp/prism
    REF v0.3.3
    SHA512 51f5d71b9420b6048c80fb833a0b5709a78c4ff9e7f9fbaf74ea4259c2808b4f2aadd76c0477df16a6c6c3fdb38e5afef83b25cc5352f526b8e64898a8968556
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
