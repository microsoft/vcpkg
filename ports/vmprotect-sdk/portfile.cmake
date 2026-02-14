vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/vmprotect-sdk
    REF "${VERSION}"
    SHA512 705b9758d11f35e90a03b39d516bfd12875541886de36e13fbc41c3dd9ba2fd334528b375e7e23ee108c24f255f90861d1fd30730b01809c71d60e78bb528cae
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
