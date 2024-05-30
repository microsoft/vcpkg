vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fribidi/fribidi
    REF v${VERSION}
    SHA512 246c904f8e6cc7eee61c03162b42dd0e0ed2163ef02d9d15b8168f0084ccdd9b625b83092915fa42f301106247e3159ad6aee0af42c37643253f7c47d0a520ef
    HEAD_REF master
    PATCHES meson-crosscompile.patch
)

set(gen_tab_subdir "share/${PORT}/gen.tab")

set(options "")
if(VCPKG_CROSSCOMPILING)
    set(gen_tab "${CURRENT_HOST_INSTALLED_DIR}/${gen_tab_subdir}")
    cmake_path(NATIVE_PATH gen_tab gen_tab)
    set(options "-Dpregenerated_tab=${gen_tab}")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -Ddocs=false
        -Dbin=false
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Define static macro
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fribidi/fribidi-common.h" "# elif defined(_WIN32) && ! defined(FRIBIDI_LIB_STATIC)" "# elif defined(_WIN32) && 0")
else()
	vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fribidi/fribidi-common.h" "# elif defined(_WIN32) && ! defined(FRIBIDI_LIB_STATIC)" "# elif defined(_WIN32) && 1")
endif()

if(VCPKG_CROSSCOMPILING)
    file(
        COPY "${gen_tab}/fribidi-unicode-version.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include/fribidi"
    )
else()
    file(
        COPY "${CURRENT_PACKAGES_DIR}/include/fribidi/fribidi-unicode-version.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/${gen_tab_subdir}"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
