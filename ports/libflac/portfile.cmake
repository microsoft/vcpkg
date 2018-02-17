include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/flac-1.3.2)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.xiph.org/releases/flac/flac-1.3.2.tar.xz"
    FILENAME "flac-1.3.2.tar.xz"
    SHA512 63910e8ebbe508316d446ffc9eb6d02efbd5f47d29d2ea7864da9371843c8e671854db6e89ba043fe08aef1845b8ece70db80f1cce853f591ca30d56ef7c3a15)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/flac-1.3.2
    PATCHES
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
