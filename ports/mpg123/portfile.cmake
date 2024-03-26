vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF "${VERSION}"
    FILENAME "mpg123-${VERSION}.tar.bz2"
    SHA512 3fbc2fcf5e17bec75e98b34ea9c6135ee5895730f127a9cdeef88060f1d49ce8b89ff6c82bb6645f575914f59e27337d4e8774d4beee6fe7c89e587ddf969502
    PATCHES
        fix-checktypesize.patch
        fix-modulejack.patch
        fix-m1-build.patch
        fix-modules-cmake-cflags.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    yasm_tool_helper(APPEND_TO_PATH)
endif()

vcpkg_list(SET options)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_list(APPEND options "-DLIBMPG123_LIBS=-lshlwapi")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/ports/cmake"
    OPTIONS
        -DUSE_MODULES=OFF
        -DBUILD_PROGRAMS=OFF
        ${options}
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
