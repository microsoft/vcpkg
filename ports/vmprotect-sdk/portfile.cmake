vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/vmprotect-sdk
    REF "${VERSION}"
    SHA512 cd9ec34dd2cf0be03c10f4bde10318201d9819a64565d86115753dd56d79634d1baf0ad77b807b469c904e18b3ce02f5c0dce6b7f254e23e645f77b4e9c101e9
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
