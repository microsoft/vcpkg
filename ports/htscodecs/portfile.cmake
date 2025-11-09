vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htscodecs
    REF "v${VERSION}"
    SHA512 3f3c249086a740be5e03ce81907f48f131758bffd43305e396f75b27fc3de6f71903a019f2b36ef0b361a1b3ff4a2da21a2bdf9be2eb6c0a2d7470687a04929a
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
