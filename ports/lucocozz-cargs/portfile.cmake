vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lucocozz/cargs
    REF v${VERSION}
    SHA512 40780e98a72fa225bdde62d45b349f558bfd32171f65393fdd8eb0da1566cb0c0083adbea620452a8bf8ff960898e216674612b94b2a556b07498a8fd7dd10d3
    HEAD_REF main
)

set(OPTIONS "")
if(NOT "regex" IN_LIST FEATURES)
    list(APPEND OPTIONS -Ddisable_regex=true)
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
