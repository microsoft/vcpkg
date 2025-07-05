vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/lucocozz/Argus/releases/download/v${VERSION}/argus-${VERSION}-source.tar.gz"
    FILENAME "argus-${VERSION}-source.tar.gz"
    SHA512 cdb6f96ac0c80d9aaa9d1e1c3161549d4fd324ac755aa61f83070665f6cba9389e6f28791c41c9d0fce2f7c4bf7f2674e65b165cac648efac7fa502d312fa2da
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

set(OPTIONS "")
if(NOT "regex" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dregex=false)
endif()
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Dbenchmarks=false
        -Dexamples=false
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
