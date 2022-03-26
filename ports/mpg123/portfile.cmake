set(MPG123_VERSION 1.29.2)
set(MPG123_HASH ffb82ffbebedeb12783338b5159bf055afd25cb77e1b705bef29f04fa50bcb2ceaf2a6418d0e111fab1151ea956fe48ba3576d978e6b0c8f4ca72c3883608ec0)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF ${MPG123_VERSION}
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
    PATCHES
        no-executables.patch
        fix-modulejack.patch
)

include("${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake")
yasm_tool_helper(APPEND_TO_PATH)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/ports/cmake"
    OPTIONS -DUSE_MODULES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
