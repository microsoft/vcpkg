vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul14
    REF v2.9.1
    SHA512 40c980f4d92a4767c4f6200e8625671b8e23ea148005518b88d394064fc371357d1d7d68f1a1a25b72b94999d4b78663b45cdcc71971c594de1be1abe2254ae5
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_meson()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
