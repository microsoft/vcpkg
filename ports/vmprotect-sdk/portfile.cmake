vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/vmprotect-sdk
    REF "${VERSION}"
    SHA512 1cf1cbb1647164ca0023f331def0d10b47c3adc97a2ab73b196d7771ef8c75d267f73788e71e57f5c2547156da27fb3f684b58487d34f09a5393d53146de260d
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
