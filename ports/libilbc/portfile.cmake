set(ILBC_VERSION 3.0.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/TimothyGu/libilbc/releases/download/v${ILBC_VERSION}/libilbc-${ILBC_VERSION}.zip"
    FILENAME "libilbc-${ILBC_VERSION}.zip"
    SHA512 a5755db093529f6a3fd8fd47da63b57cffff1d3babef443d92f7c5a250ce8d1585adfba525c4037b142d9f00f1675a5054c172bf936be280dfcc22ed553c94c6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${ILBC_VERSION}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_copy_tools(TOOL_NAMES ilbc_test AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
