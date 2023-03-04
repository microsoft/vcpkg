vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF "${VERSION}"
    FILENAME "mpg123-${VERSION}.tar.bz2"
    SHA512 eca285382ee3e780353834addf1336c4a2f8f11256af22f95e11efa243de669761c083c86ddfc6ac8c02a920a3c4ab4ad767efa2739fb052e9719f35ef407bc3
    PATCHES
        fix-modulejack.patch
        fix-m1-build.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    include("${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake")
    yasm_tool_helper(APPEND_TO_PATH)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/ports/cmake"
    OPTIONS
        -DUSE_MODULES=OFF
        -DBUILD_PROGRAMS=OFF
    MAYBE_UNUSED_VARIABLES
        BUILD_PROGRAMS
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_OSX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
