vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO   addisonElliott/nifticlib 
    REF 8a301274a95a3124c4e945e353884c50460e8e40
    SHA512 d6ce69fdd6926354f00e9cccbdab280dce77d69d02d9686be256cab18b81198a4682b8aeeaa82fe53a30b18142c695f9b7758a1cb4d847199b40c877466097a3
    HEAD_REF master
    PATCHES zlib_include.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DBUILD_TESTING=OFF"
        ${FEATURE_OPTIONS}
        ${ADDITIONAL_OPTIONS}
        
    OPTIONS_DEBUG   ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES nifti_stats nifti_tool nifti1_test AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
