vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF "${VERSION}"
    FILENAME "mpg123-${VERSION}.tar.bz2"
    SHA512 694743802bb7be0f4a39bf62e681ae0bfed769cb87dc6c5b6fb5f9245966631efb5c5b9bd58588f7af55ced5d020f97c8a54993e71b5295bc45ebd152473f40e
    PATCHES
        have-fpu.diff
        pkgconfig.diff
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
        CMAKE_DISABLE_FIND_PACKAGE_ALSA
        CMAKE_DISABLE_FIND_PACKAGE_PkgConfig
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
