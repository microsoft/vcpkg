vcpkg_download_distfile(ARCHIVE
    URLS "https://angelcode.com/angelscript/sdk/files/angelscript_2.34.0.zip"
    FILENAME "angelscript_2.34.0.zip"
    SHA512 c26dba452ab52c300da9c95fde8398acf4840cbc0e653ededf978d4a3e942cfe5b77292c74c49dc0279250a27cfd324c696c49d139a97c844b2a1eead9aae2f4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
       mark-threads-private.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/angelscript/projects/cmake
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Angelscript)

# Copy the addon files
if("addons" IN_LIST FEATURES)
	file(INSTALL ${SOURCE_PATH}/add_on/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/angelscript FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()

file(INSTALL ${CURRENT_PORT_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
