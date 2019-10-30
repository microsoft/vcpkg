include(vcpkg_common_functions)

vcpkg_download_distfile(FLAC_MAX_MIN_PATCH
    URLS "https://github.com/xiph/flac/commit/64f47c2d71ffba5aa8cd1d2a447339fd95f362f9.patch"
    FILENAME "flac-max-min.patch"
    SHA512 7ce9ccf9f081b478664cccd677c10269567672a8aa3a60839ef203b3d0a626d2b2c2f34d4c7fc897c31a436d7c22fb740bca5449a465dab39d60655417fe7772)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/flac
    REF 1.3.2
    SHA512 d0e177cadee371940516864bf72e1eb3d101a5f2779c854ecb8a3361a654a9b9e7efd303c83e2f308bacc7e54298d37705f677e2b955d4a9fe3470c364fa45f3
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
