vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/libatomic_ops
    REF "v${VERSION}"
    SHA512 2b33aaaef0b4ed995044ba818b6acfedf1a70efea419338eece90b3cb453d7dba6ca55cd7fb36dce6143ede511284e75b6e17cd773d8da8f32d7888cb029dfd1
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
