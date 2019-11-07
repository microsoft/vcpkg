include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/flac
    REF f764434a39e8a8715d5871bb263189e5a7298280 # 1.3.3
    SHA512 d44ddd4f83eb5ff4b8ad07c860db1f2f66e0638ea498b08df27fe079bc33f1acdeeca9d050df3d1c22a4de294976901971bd61f578df9856756be04f102567d2
    HEAD_REF master
    PATCHES
        uwp-library-console.patch
        fix-win_utf8_io.patch
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBFLAC_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}
    OPTIONS_DEBUG
        -DLIBFLAC_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(APPEND ${CURRENT_PACKAGES_DIR}/include/FLAC/export.h "#undef FLAC_API\n#define FLAC_API\n")
    file(APPEND ${CURRENT_PACKAGES_DIR}/include/FLAC++/export.h "#undef FLACPP_API\n#define FLACPP_API\n")
endif()

# This license (BSD) is relevant only for library - if someone would want to install
# FLAC cmd line tools as well additional license (GPL) should be included
file(COPY ${SOURCE_PATH}/COPYING.Xiph DESTINATION ${CURRENT_PACKAGES_DIR}/share/libflac)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libflac/COPYING.Xiph ${CURRENT_PACKAGES_DIR}/share/libflac/copyright)
