vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/bde-tools 
    REF "${VERSION}"
    HEAD_REF main
    SHA512 e59560810acfe562d85a13585d908decce17ec76c89bd61f43dac56cddfdf6c56269566da75730f8eda14b5fc046d2ebce959b24110a428e8eac0e358d2597c2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Necessary since bde-tools only provides CMake modules and scripts
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
