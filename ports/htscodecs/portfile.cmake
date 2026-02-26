vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htscodecs
    REF "v${VERSION}"
    SHA512 ef1017c432937926a6d7723e5e012a5e38bdbbf3ffd2f35b0cbac4a804f8f3163058c4f736a6998151eb4e73a127fa52d1ac4d734d05a35d7e5b3fa60ebf2a28
    HEAD_REF master
    PATCHES
        0001-no-tests.patch # https://github.com/samtools/htscodecs/pull/120
        configure_bz2.patch
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
