vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htslib
    REF "${VERSION}"
    SHA512 6df1a493ac9f13cae5a510537bdf83aa9635a79efe635b8a5a5cbd89345c75c9a42e686c4f0497761ddfad3b86a9814ed35ba2ac340d0f1c7b5e2e186b152875
    HEAD_REF develop
    PATCHES
        0001-set-linkage.patch
        0002-pthread-flag.patch
        0003-no-tests.patch
        0004-fix-find-htscodecs.patch
        0005-remove-duplicate-lhts.patch # https://github.com/samtools/htslib/pull/1852
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
