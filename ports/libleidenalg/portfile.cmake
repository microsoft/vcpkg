vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO theAeon/libleidenalg
    REF 748dfca386b997fe5a140e21b9ef0f78a6e95ee6
    SHA512 7aeab3f870c5e0be8004c0daa2b48ca3ffd3589f9553b9599846ba788a425ee28b6accfa761960a97a280259d47c7be721cca0ae2ecc06c7262199cd6d30c880
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
