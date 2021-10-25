set(MPG123_VERSION 1.28.0)
set(MPG123_HASH 4e333ee4f3bbebcfff280cf286265e969a8da93b9043d03c0189e22cd40918b07bf12181bd06141d4479c78bc0d0ed472e0d3bb61b2fdb96fe9f7cd48f9a6b77)

set(PATCHES "")
if(VCPKG_TARGET_IS_UWP)
    set(PATCHES
        0002-fix-libmpg123-uwp-build.patch
        0003-fix-libout123-uwp-build.patch
        0004-fix-libsyn123-uwp-build.patch
    )
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF ${MPG123_VERSION}
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
    PATCHES
        0001-fix-checkcpuarch-path.patch
        no-executables.patch
        ${PATCHES}
)

include(${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake)
yasm_tool_helper(APPEND_TO_PATH)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/ports/cmake
    OPTIONS -DUSE_MODULES=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
