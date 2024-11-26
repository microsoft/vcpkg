vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF "${VERSION}"
    FILENAME "mpg123-${VERSION}.tar.bz2"
    SHA512 71f7cf6035c489934400528d0eaf0c1104417867990dd0abcc99c682818ef1f3e99dbee9dcdd888d88ed172a8950d5df515b755a5c1c1b54fc56a28584ceef8c
    PATCHES
        have-fpu.diff
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
        -DCMAKE_DISABLE_FIND_PACKAGE_ALSA=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON
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
