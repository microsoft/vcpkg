vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htslib
    REF "${VERSION}"
    SHA512 b9de3769db6153f66348c7c4ffbfc5ac7cd4a4d4450c9d1c5ea8fdd8f4f9d38d1d0ba5b4ac9c53f1a754d3985dc483fe22e76f93a8bbe8ae29ef3b98136e7d2e
    HEAD_REF develop
    PATCHES
        0001-set-linkage.patch
        0002-pthread-flag.patch
        0003-no-tests.patch
        0004-fix-find-htscodecs.patch
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
