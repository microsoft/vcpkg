include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF v8.0.4
    SHA512 f3c178c9cab9d9df9ecdad5ac5661c916518d29b0eaca24efe569cb757c386c118ad4389851107597d99ff1bbe99b46383cce73dfd01be983196aa57c9626a4a
    HEAD_REF master
    PATCHES
        001-install-libraries.patch 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_RELEASE
        -DBDWGC_INSTALL_TOOLS=ON
    OPTIONS_DEBUG 
        -DBDWGC_SKIP_HEADERS=ON 
        -DBDWGC_INSTALL_TOOLS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies(TOOL_DIR "tools/cord")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.QUICK DESTINATION ${CURRENT_PACKAGES_DIR}/share/bdwgc RENAME copyright)
