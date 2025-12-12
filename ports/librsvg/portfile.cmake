# port update requires rust/cargo

string(REGEX REPLACE "^([0-9]*[.][0-9]*)[.].*" "\\1" MAJOR_MINOR "${VERSION}")

# NOTE: Using GitHub mirror to avoid Anubis check failure on GNOME GitLab
# https://github.com/microsoft/vcpkg/issues/48350
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/librsvg
    REF librsvg-gtk-${VERSION}
    SHA512 1fe06d7e745a53f3aee7b1942f7551c5716ec6abf328fa395006a7aede9f4ef242d604d5f8069c397d86ec3ac095daf49b18b2b34abc67fdcd4a113207fd6a96
    HEAD_REF master # branch name
    PATCHES
        fix-libxml2-2.13.5.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-Dtests=disabled"
        "-Drsvg-convert=disabled"
        "-Drsvg-view-3=disabled"
    ADDITIONAL_BINARIES
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

block(SCOPE_FOR VARIABLES)
    set(RSVG_API_MAJOR_VERSION 2)
    set(prefix "")
    set(libdir [[${prefix}/lib]])
    set(exec_prefix [[${prefix}]])
    set(includedir [[${prefix}/include]])
    configure_file("${SOURCE_PATH}/librsvg.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/librsvg-${MAJOR_MINOR}.pc" @ONLY)
    if(NOT VCPKG_BUILD_TYPE)
        configure_file("${SOURCE_PATH}/librsvg.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/librsvg-${MAJOR_MINOR}.pc" @ONLY)
    endif()
endblock()

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(GLOB_RECURSE pc_files "${CURRENT_PACKAGES_DIR}/*.pc")
    foreach(pc_file IN LISTS pc_files)
        vcpkg_replace_string("${pc_file}" " -lm" "")
    endforeach()
endif()

# install headers
set(GEN_HEADERS_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
if(NOT VCPKG_BUILD_TYPE)
    set(GEN_HEADERS_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
endif()

file(COPY
        "${SOURCE_PATH}/librsvg/rsvg.h"
        "${SOURCE_PATH}/rsvg-cairo.h"
        "${GEN_HEADERS_DIR}/librsvg-features.h"
        "${GEN_HEADERS_DIR}/librsvg-enum-types.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/librsvg-${MAJOR_MINOR}/librsvg"
)

file(COPY "${CURRENT_PORT_DIR}/unofficial-librsvg-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-librsvg")
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
