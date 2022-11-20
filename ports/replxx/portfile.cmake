vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AmokHuginnsson/replxx
    REF release-0.0.4
    SHA512 5b87d3b53a99ead00a1ff0ee7a158b13339446682da630989643db7d47d4877d5d97c46954dc51cd282c8130c62a4fed5ce74d73d193690a1518fef974c8b497
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/replxx")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
