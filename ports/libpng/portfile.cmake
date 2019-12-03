include(vcpkg_common_functions)

set(LIBPNG_VER 1.6.37)

# Download the apng patch
set(LIBPNG_APNG_OPTION )
if ("apng" IN_LIST FEATURES)
    set(LIBPNG_APG_PATCH_NAME libpng-${LIBPNG_VER}-apng.patch)
    set(LIBPNG_APG_PATCH_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIBPNG_APG_PATCH_NAME})
    if (NOT EXISTS ${LIBPNG_APG_PATCH_PATH})
        vcpkg_download_distfile(LIBPNG_APNG_PATCH_ARCHIVE
            URLS "https://downloads.sourceforge.net/project/libpng-apng/libpng16/${LIBPNG_VER}/${LIBPNG_APG_PATCH_NAME}.gz"
            FILENAME "${LIBPNG_APG_PATCH_NAME}.gz"
            SHA512 226adcb3a8c60f2267fe2976ab531329ae43c2603dab4d0cf8f16217d64069936b879f3d6516b75d259c47d6f5c5b1f24f887602206c8e46abde0fb7f5c7946b
        )

        vcpkg_find_acquire_program(7Z)

        vcpkg_execute_required_process(
            COMMAND ${7Z} x ${LIBPNG_APNG_PATCH_ARCHIVE} -aoa
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
            LOGNAME extract-patch.log
        )
    endif()

    set(APNG_EXTRA_PATCH ${LIBPNG_APG_PATCH_PATH})
    set(LIBPNG_APNG_OPTION "-DPNG_PREFIX=a")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glennrp/libpng
    REF v${LIBPNG_VER}
    SHA512 ccb3705c23b2724e86d072e2ac8cfc380f41fadfd6977a248d588a8ad57b6abe0e4155e525243011f245e98d9b7afbe2e8cc7fd4ff7d82fcefb40c0f48f88918
    HEAD_REF master
    PATCHES
        use_abort.patch
        cmake.patch
        ${APNG_EXTRA_PATCH}
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
        ${LIBPNG_APNG_OPTION}
        -DPNG_STATIC=${PNG_STATIC_LIBS}
        -DPNG_SHARED=${PNG_SHARED_LIBS}
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
        OPTIONS_DEBUG
            -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/libpng)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
