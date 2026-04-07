vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/oboe
    REF ${VERSION}
    SHA512 ce4011afe7345370d4ead3b891cd69a5ef224b129535783586c0ca75051d303ed446e6c7f10bde8da31fff58d6e307f1732a3ffd03b249f9ef1fd48fd4132715
    HEAD_REF master
    PATCHES
        fix_install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
