string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gimp.org/pub/babl/${VERSION_MAJOR_MINOR}/babl-${VERSION}.tar.xz"
    FILENAME "babl-${VERSION}.tar.xz"
    SHA512 953037386e1763b28385f0f1802a657e2b918b5db3932cc62e75aa32c36b36b0513258f1b5548dfebedb51fb6de47412503ea8f8aff4ce79c314e33a28d27166
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        support-plugins.patch
        gir-header-only-on-windows.patch
        remove-consistency-check.patch
)

set(feature_options "")
set(debug_options "")
set(release_options "")
if("cmyk-icc" IN_LIST FEATURES)
    list(APPEND feature_options "-Dwith-lcms=enabled")
else()
    list(APPEND feature_options "-Dwith-lcms=disabled")
endif()

if("introspection" IN_LIST FEATURES)
    list(APPEND feature_options "-Denable-gir=true")
    if(VCPKG_TARGET_IS_WINDOWS)
        # The Windows debug scanner path is currently brittle; generate the
        # GIR/typelib from release only and package those artifacts.
        list(APPEND debug_options "-Denable-gir=false")
        list(APPEND release_options "-Denable-gir=true")
    endif()
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND feature_options "-Denable-gir=false")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${feature_options}
        -Dwith-docs=false
    OPTIONS_DEBUG
        ${debug_options}
    OPTIONS_RELEASE
        ${release_options}
    ADDITIONAL_BINARIES
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES babl AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
