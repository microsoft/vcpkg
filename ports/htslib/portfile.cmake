vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtools/htslib
    REF "${VERSION}"
    SHA512 459af7d11f5ad2e15a07b393d36c15c9498ec709b301e62155ae31588bf40f7a536286a79b7324286f9d4dd337bf523cb22a0d15094c97a87207ad1aea1bdbc7
    HEAD_REF develop
)

set(FEATURE_OPTIONS)

macro(enable_feature feature switch)
    if("${feature}" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS "--enable-${switch}")
        set(has_${feature} 1)
    else()
        list(APPEND FEATURE_OPTIONS "--disable-${switch}")
        set(has_${feature} 0)
    endif()
endmacro()

enable_feature("bzip2" "bz2")
enable_feature("curl" "libcurl")
enable_feature("gcs" "gcs")
enable_feature("lzma" "lzma")
enable_feature("plugins" "plugins")
enable_feature("s3" "s3")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --with-external-htscodecs
        ${FEATURE_OPTIONS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
