vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/flac
    REF 1.3.3
    SHA512 4644dc8fd45e775d0e6210de2b082996692675307a7b7d359827730cc4cede9c2e1df46f4386023d83da9bafa6b3218d24012bf532f459087e311f14863747ec
    HEAD_REF master
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
