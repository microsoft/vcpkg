vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/vmprotect-sdk
    REF "${VERSION}"
    SHA512 bddadc22c1be77d581f9a47952c174f25b52a5d5a39850f07fb0116e57dfee4df1180403e91ef0843fceb921863674cb03c2b0746fa783a559355fa7f7ecb3dc
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vmprotect_sdk" PACKAGE_NAME "vmprotect_sdk")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
