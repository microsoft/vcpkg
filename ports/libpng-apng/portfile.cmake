include(vcpkg_common_functions)

set(LIBPNG_APNG_VERSION 1.6.36)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glennrp/libpng
    REF v${LIBPNG_APNG_VERSION}
    SHA512 aeb00b48347c9e84d31995b3fe7e40580029734aa8103d774eee5745f5ca1fd1fd91a15f32d492277ab94346e4e7f731ee9bfea1783f930094f9f87eb3d9397d
    HEAD_REF master
)

vcpkg_download_distfile(LIBPNG_APNG_PATCH_ARCHIVE
    URLS "https://downloads.sourceforge.net/project/libpng-apng/libpng16/${LIBPNG_APNG_VERSION}/libpng-${LIBPNG_APNG_VERSION}-apng.patch.gz"
    FILENAME "libpng-${LIBPNG_APNG_VERSION}-apng.patch.gz"
    SHA512 8fa213204768b058459ffd5eae6b3661c3f185d3baf1913da4337e7b7855e567f2525e7f67411c32fa8cb177a5f93d538c3d0ce17a94d4aa71bd9cffabe8b311
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
        ${CMAKE_CURRENT_LIST_DIR}/skip-install-symlink.patch
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
        -DSKIP_INSTALL_SYMLINK=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/libpng16_static.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpng16_static.lib ${CURRENT_PACKAGES_DIR}/lib/libpng16.lib)
    endif()
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/libpng16_staticd.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpng16_staticd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libpng16d.lib)
    endif()
endif()

# Remove CMake config files as they are incorrectly generated and everyone uses built-in FindPNG anyway.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libpng ${CURRENT_PACKAGES_DIR}/debug/lib/libpng)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpng-apng)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libpng-apng/LICENSE ${CURRENT_PACKAGES_DIR}/share/libpng-apng/copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/png)
endif()
