vcpkg_download_distfile(ARCHIVE
    URLS "https://angelcode.com/angelscript/sdk/files/angelscript_2.35.1.zip"
    FILENAME "angelscript_2.35.1.zip"
    SHA512 b15083c7a77434c291e72ea82cfbab7734fa79df654d911a822f306d526669ebe9e55a981e8a1914deda0d2a52ebdc0ffb51a4179f307632c8c7d74b1abc69fa
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
       mark-threads-private.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/angelscript/projects/cmake
    PREFER_NINJA
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Angelscript)

# Copy the addon files
if("addons" IN_LIST FEATURES)
    file(INSTALL ${SOURCE_PATH}/add_on/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/angelscript FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()

file(INSTALL ${CURRENT_PORT_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
