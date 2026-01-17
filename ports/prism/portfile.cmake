vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ethindp/prism
    REF v0.3.2
    SHA512 913b2c7918cfc19d1ab98d7a4c063b463ea539d4188b218844f166c5d8895453e10c357d646899be2653345763e910f5ba0c2f4dd285e80e0b875aaf92a61013
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
