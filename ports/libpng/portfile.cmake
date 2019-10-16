include(vcpkg_common_functions)

set(LIBPNG_VER 1.6.37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glennrp/libpng
    REF v${LIBPNG_VER}
    SHA512 ccb3705c23b2724e86d072e2ac8cfc380f41fadfd6977a248d588a8ad57b6abe0e4155e525243011f245e98d9b7afbe2e8cc7fd4ff7d82fcefb40c0f48f88918
    HEAD_REF master
    PATCHES
        use-abort-on-all-platforms.patch
        fix-libm-unix.patch
)

# Download the apng patch
set(LIBPNG_APNG_OPTION )
if ("apng" IN_LIST FEATURES AND NOT EXISTS ${SOURCE_PATH}/../libpng-${LIBPNG_VER}-apng.patch)
    vcpkg_download_distfile(LIBPNG_APNG_PATCH_ARCHIVE
        URLS "https://downloads.sourceforge.net/project/libpng-apng/libpng16/${LIBPNG_VER}/libpng-${LIBPNG_VER}-apng.patch.gz"
        FILENAME "libpng-${LIBPNG_VER}-apng.patch.gz"
        SHA512 226adcb3a8c60f2267fe2976ab531329ae43c2603dab4d0cf8f16217d64069936b879f3d6516b75d259c47d6f5c5b1f24f887602206c8e46abde0fb7f5c7946b
    )
    
    vcpkg_find_acquire_program(7Z)

    vcpkg_execute_required_process(
        COMMAND ${7Z} x ${LIBPNG_APNG_PATCH_ARCHIVE} -aoa
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME extract-patch.log
    )
    
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            skip-install-symlink.patch
            ${SOURCE_PATH}/../libpng-${LIBPNG_VER}-apng.patch
    )
    
    set(LIBPNG_APNG_OPTION "-DPNG_PREFIX=a")
endif()

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
        ${LIBPNG_APNG_OPTION}
        -DPNG_STATIC=${PNG_STATIC_LIBS}
        -DPNG_SHARED=${PNG_SHARED_LIBS}
        -DPNG_TESTS=OFF
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/libpng)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libpngConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpng)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpng)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libpng/LICENSE ${CURRENT_PACKAGES_DIR}/share/libpng/copyright)

vcpkg_copy_pdbs()

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/png)
endif()
