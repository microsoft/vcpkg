vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fribidi/fribidi
    REF v1.0.12
    SHA512 a3a63e1dde1cffb097376df0b34522700cff600da61bdafd6f4f50db6937383b9f73a82081cb1a7f2e1946ba07fea13e2880a4250b1508850bffa500046a7fa5
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
file(READ "${CURRENT_PACKAGES_DIR}/include/fribidi/fribidi-common.h" FRIBIDI_COMMON_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "#ifndef FRIBIDI_LIB_STATIC" "#if 0" FRIBIDI_COMMON_H "${FRIBIDI_COMMON_H}")
else()
    string(REPLACE "#ifndef FRIBIDI_LIB_STATIC" "#if 1" FRIBIDI_COMMON_H "${FRIBIDI_COMMON_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/fribidi/fribidi-common.h" "${FRIBIDI_COMMON_H}")

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
