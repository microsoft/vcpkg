set(MPG123_VERSION 1.26.5)
set(MPG123_HASH 7574331afaecf3f867455df4b7012e90686ad6ac8c5b5e820244204ea7088bf2b02c3e75f53fe71c205f9eca81fef93f1d969c8d0d1ee9775dc05482290f7b2d)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF ${MPG123_VERSION}
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
)

include(${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake)
yasm_tool_helper(APPEND_TO_PATH)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/ports/cmake
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
