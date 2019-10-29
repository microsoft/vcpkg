include(vcpkg_common_functions)

vcpkg_download_distfile(FLAC_MAX_MIN_PATCH
    URLS "https://github.com/xiph/flac/commit/64f47c2d71ffba5aa8cd1d2a447339fd95f362f9.patch"
    FILENAME "flac-max-min.patch"
    SHA512 7ce9ccf9f081b478664cccd677c10269567672a8aa3a60839ef203b3d0a626d2b2c2f34d4c7fc897c31a436d7c22fb740bca5449a465dab39d60655417fe7772)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/flac
    REF f764434a39e8a8715d5871bb263189e5a7298280 # 1.3.3
    SHA512 d44ddd4f83eb5ff4b8ad07c860db1f2f66e0638ea498b08df27fe079bc33f1acdeeca9d050df3d1c22a4de294976901971bd61f578df9856756be04f102567d2
    HEAD_REF master
    PATCHES
        "${FLAC_MAX_MIN_PATCH}"
        "${CMAKE_CURRENT_LIST_DIR}/uwp-library-console.patch"
        "${CMAKE_CURRENT_LIST_DIR}/uwp-createfile2.patch"
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
