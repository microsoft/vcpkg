set(VCPKG_BUILD_TYPE release)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/igormironchik/cfgfile/releases/download/0.2.8.2.1/cfgfile-0.2.8.2.1-full.tar.gz"
    FILENAME "cfgfile02821.tar.gz"
    SHA512 b51bed3e83673dcab281c90c8df7a14746ed475113327a84a20e9fa474a9aad79fd90cac7d8eb467d94881921b3a3a9b33d2bf793da975d64e3d52acca153ed3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_EXAMPLES=0 -DBUILD_TESTS=0
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/cfgfile)

vcpkg_copy_tools(TOOL_NAMES cfgfile.generator)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cfgfile RENAME copyright)
