vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/libatomic_ops
    REF "v${VERSION}"
    SHA512 6b0ab1c01600346413184f66eaff1f707d1bc46fad9fd52ac855f2c66a55097dfad620c68b898459527142c1eb7ba50fde34498f962f24cec83268500c5bcccb
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Denable_docs=OFF
    OPTIONS_DEBUG
        -Dinstall_headers=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME atomic_ops CONFIG_PATH lib/cmake/atomic_ops)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
