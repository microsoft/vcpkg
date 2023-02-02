vcpkg_download_distfile(ARCHIVE
    URLS "https://angelcode.com/angelscript/sdk/files/angelscript_2.36.0.zip"
    FILENAME "angelscript_2.36.0.zip"
    SHA512 afd2b9096d0b62bc3d182d684fe34ddc8e9520af7734eea1f1a5c7d3439a28a1be7502faf692080cb0c4591799b7fea09fc8c4ccf25b8ec63a3d306e678682ff
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        mark-threads-private.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/angelscript/projects/cmake"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Angelscript)

# Copy the addon files
if("addons" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/add_on/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/angelscript" FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()

file(INSTALL "${SOURCE_PATH}/docs/manual/doc_license.html" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
