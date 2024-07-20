vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htscodecs
    REF "v${VERSION}"
    SHA512 7533570b8b1cad0b9ed118170e5a9ff34fdde40b090f4ba3756f7899e2cd7230f8172425ecf6bd7b83b0b0b1a2a24f3d21795db7f0bc2c3add0a55342b970d1a
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
