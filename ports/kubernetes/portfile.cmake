vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF "v${VERSION}"
    SHA512 8324049f030201e9a031556a799defcbc90fe41bc7b40e2997ed0c706f97660af39b84d679065e83adce85b66c832d406468a9c543367b64c5b702fc5896ee07
    HEAD_REF master
    PATCHES
        001-fix-destination.patch
        002-disable-werror.patch
)
file(COPY "${CURRENT_PORT_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}/kubernetes")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/kubernetes"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kubernetes)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
