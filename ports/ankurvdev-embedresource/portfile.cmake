vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ankurvdev/embedresource
    REF "v${VERSION}"
    SHA512 90b4e40b84cd5b6de155a17890b5d8094cf772f56657230ad13a0c51a332e84fa4a38d8640a3890ae4b521a2eb897666d8c3f58e7cd9dc98e6eb3d55c84dfe44
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_copy_tools(TOOL_NAMES embedresource AUTO_CLEAN)

file(READ "${CURRENT_PACKAGES_DIR}/share/embedresource/EmbedResourceConfig.cmake" config_contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/embedresource/EmbedResourceConfig.cmake"
"find_program(
    EMBEDRESOURCE_EXECUTABLE embedresource
    PATHS
        \"\${CMAKE_CURRENT_LIST_DIR}/../../../${HOST_TRIPLET}/tools/${PORT}\"
    NO_DEFAULT_PATH
    REQUIRED)
${config_contents}"
)
