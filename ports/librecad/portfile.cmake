set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibreCAD/LibreCAD
    REF "v${VERSION}"
    SHA512 c8c65f2e0405f8193c37ce0a5a395320635138967d4f948b516453f48d286fe9f4afee6ac9edd93690a5c9977b4c072c7319b5a95b81bca82ad055f332a7f064
    HEAD_REF master
    PATCHES
        dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_tools(
    TOOL_NAMES LibreCAD
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
