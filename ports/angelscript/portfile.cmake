vcpkg_download_distfile(ARCHIVE
    URLS "https://angelcode.com/angelscript/sdk/files/angelscript_${VERSION}.zip"
    FILENAME "angelscript_${VERSION}.zip"
    SHA512 ba7d88a42e1443fd12196da723538b24d999bc7ade92c0231237e4c5b8b0cb586931262c941898c62f454fd453d653724c74b6857e8a43eea6e34669795fc9cd
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        mark-threads-private.patch
        fix-dependency.patch
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/docs/manual/doc_license.html")
