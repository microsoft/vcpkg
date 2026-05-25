vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xdp-project/xdp-tools
    REF "v${VERSION}"
    SHA512 13c045af6a039cfcfbd5987a34c613a4f8767a1371d5d954d51fdaeed8dc8649388f87dd209135bfa5d6f759a9ee8316ee2b4e6779c3c16869d9f1d046bb4713
    HEAD_REF main
    PATCHES
        0001-disable-unused-deps-check.patch
        0002-enable-static-or-shared.patch
        0003-suppress-object-file-install.patch
        0004-disable-tests.patch
        0005-disable-docs.patch
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
)

set(OPTIONS "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND OPTIONS "BUILD_STATIC=True")
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "BUILD_SHARED=True")
endif()

vcpkg_make_install(
    TARGETS libxdp_install
    OPTIONS
        ${OPTIONS}
    OPTIONS_DEBUG
        "PREFIX=${CMAKE_PACKAGES_DIR}/debug"
    OPTIONS_RELEASE
        "PREFIX=${CMAKE_PACKAGES_DIR}"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
