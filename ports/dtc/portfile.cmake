if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # library does not explicitely export its symbols.
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dgibson/dtc
    REF "v${VERSION}"
    SHA512 93a65d2e18995907f70d3033d83ac9b246e1589dff255c4e018bfd2c2ff8b9153130728ebc28d1d0adba7e077d9354de7a781f95f5c3f636547c08338d85ef8d
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtools=false
        -Dyaml=disabled
        -Dvalgrind=disabled
        -Dpython=disabled
        -Dtests=false
)

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/README.license"
    "${SOURCE_PATH}/BSD-2-Clause"
    "${SOURCE_PATH}/GPL"
)
