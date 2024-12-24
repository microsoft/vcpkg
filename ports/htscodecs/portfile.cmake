vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htscodecs
    REF "v${VERSION}"
    SHA512 5e3e1f916cb14fe7e1292f3a07e9d9704b11be38014db5884b334235c25dbe61dffecf3f12c448a7a13f65c6d19dbc7cc5c77ba0861b31a0375d71030dd02480
    HEAD_REF master
    PATCHES
        0001-no-tests.patch # https://github.com/samtools/htscodecs/pull/120
)

set(FEATURE_OPTIONS "")

macro(enable_feature feature switch)
    if("${feature}" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS "--enable-${switch}")
    else()
        list(APPEND FEATURE_OPTIONS "--disable-${switch}")
    endif()
endmacro()

enable_feature("bzip2" "bz2")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
