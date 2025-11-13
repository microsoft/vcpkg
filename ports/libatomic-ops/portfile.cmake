vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/libatomic_ops
    REF "v${VERSION}"
    SHA512 09ea0934e223898b6d6d615813a42e25237ecc9c728b454cabe25a031a72383fb3eccecf36157b9625ca8407363157815b14b8098541453a4d799175d82a710c
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
