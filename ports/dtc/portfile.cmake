if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # library does not explicitely export its symbols.
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dgibson/dtc
    REF "v${VERSION}"
    SHA512 5cf48c8bd426919bb8aad6a8866e063305eca830547f8ceb5fe7746bc85a8d6a0a1e13fd29432cb389d3d51337368f217077aabf9436b526e77d425b33167694
    HEAD_REF main
    PATCHES
        0001-enable-static-or-shared.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(STATIC_BUILD true)
else()
    set(STATIC_BUILD false)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtools=false
        -Dyaml=disabled
        -Dvalgrind=disabled
        -Dpython=disabled
        -Dtests=false
        "-Dstatic-build=${STATIC_BUILD}"
)

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/README.license"
    "${SOURCE_PATH}/BSD-2-Clause"
    "${SOURCE_PATH}/GPL"
)
