include(vcpkg_common_functions)

set(LIBPNG_APNG_VERSION 1.6.34)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glennrp/libpng
    REF v${LIBPNG_APNG_VERSION}
    SHA512 23b6112a1d16a34c8037d5c5812944d4385fc96ed819a22172776bdd5acd3a34e55f073b46087b77d1c12cecc68f9e8ba7754c86b5ab6ed3016063e1c795de7a
    HEAD_REF master
)

vcpkg_download_distfile(LIBPNG_APNG_PATCH_ARCHIVE
    URLS "https://downloads.sourceforge.net/project/libpng-apng/libpng16/${LIBPNG_APNG_VERSION}/libpng-${LIBPNG_APNG_VERSION}-apng.patch.gz"
    FILENAME "libpng-${LIBPNG_APNG_VERSION}-apng.patch.gz"
    SHA512 0777b8e55aeee207ee92479f2258ef1f60f16d7951fdbc6d89a80ef533b86dadecd1ef659d6fe7602d8ea3a8e711a096b0f77ee09b993799b73dfffddfe5dd3c
)

vcpkg_find_acquire_program(7Z)

vcpkg_execute_required_process(
    COMMAND ${7Z} x ${LIBPNG_APNG_PATCH_ARCHIVE} -aoa
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
    LOGNAME extract-patch.log
)

find_program(GIT NAMES git git.cmd)

# sed and awk are installed with git but in a different directory
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
set(AWK_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")
set(ENV{PATH} "$ENV{PATH};${AWK_EXE_PATH}")

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/use-abort-on-all-platforms.patch
        ${CURRENT_BUILDTREES_DIR}/src/libpng-${LIBPNG_APNG_VERSION}-apng.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PNG_STATIC_LIBS OFF)
    set(PNG_SHARED_LIBS ON)
else()
    set(PNG_STATIC_LIBS ON)
    set(PNG_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPNG_STATIC=${PNG_STATIC_LIBS}
        -DPNG_SHARED=${PNG_SHARED_LIBS}
        -DPNG_TESTS=OFF
        -DPNG_PREFIX=a
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpng16_static.lib ${CURRENT_PACKAGES_DIR}/lib/libpng16.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpng16_staticd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libpng16d.lib)
endif()

# Remove CMake config files as they are incorrectly generated and everyone uses built-in FindPNG anyway.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libpng ${CURRENT_PACKAGES_DIR}/debug/lib/libpng)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpng-apng)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libpng-apng/LICENSE ${CURRENT_PACKAGES_DIR}/share/libpng-apng/copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
