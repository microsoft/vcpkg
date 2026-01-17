string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gimp.org/pub/babl/${VERSION_MAJOR_MINOR}/babl-${VERSION}.tar.xz"
    FILENAME "babl-${VERSION}.tar.xz"
    SHA512 6a361135045566b5a35b7c2df8e9f0a0b1c6e910aa73aafecb621446d333bcbfc50e925ceac675b83b548a872d53eba2c03bcbccb504b47089c737b0ffb53d9d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        remove-consistency-check.patch
)

set(feature_options "")
if("cmyk-icc" IN_LIST FEATURES)
    list(APPEND feature_options "-Dwith-lcms=enabled")
else()
    list(APPEND feature_options "-Dwith-lcms=disabled")
endif()

if("introspection" IN_LIST FEATURES)
    list(APPEND feature_options "-Denable-gir=true")
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND feature_options "-Denable-gir=false")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${feature_options}
        -Dwith-docs=false
    ADDITIONAL_BINARIES
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
