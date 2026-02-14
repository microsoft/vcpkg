vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/vmprotect-sdk
    REF "${VERSION}"
    SHA512 f21bfb34c09844cb4cb87b9fb080cb2f66672c293b22e7b24a0c6a9e1e5b3ab9b77690af1f86ae8afc18fc8968ae8002aabac7baf87f442167e2fe89c5753eae
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
