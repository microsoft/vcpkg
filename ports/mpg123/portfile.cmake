vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF "${VERSION}"
    FILENAME "mpg123-${VERSION}.tar.bz2"
    SHA512 5dd550e06f5d0d432cac1b7e546215e56378b44588c1a98031498473211e08bc4228de45be41f7ba764f7f6c0eb752a6501235bcc3712c9a8d8852ae3c607d98
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
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
