vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htslib
    REF "${VERSION}"
    SHA512 bb1a9c03d3b9f113a030c2c36e7c354e60395f7deb9377ca1993e4d26fb1e1df69570a60a5a4696841d29266df1052558eed7ddb877d1248a82103520a695150
    HEAD_REF develop
    PATCHES
        0001-set-linkage.patch
        0002-pthread-flag.patch
        0003-no-tests.patch
        0004-fix-find-htscodecs.patch
        bzip2-use-pkgconfig.diff
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
enable_feature("lzma" "lzma")

if("deflate" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "--with-libdeflate")
else()
    list(APPEND FEATURE_OPTIONS "--without-libdeflate")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --with-external-htscodecs
        --disable-libcurl
        --disable-gcs
        --disable-s3
        --disable-plugins
        ${FEATURE_OPTIONS}
)

vcpkg_install_make(
    INSTALL_TARGET install-${VCPKG_LIBRARY_LINKAGE}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
