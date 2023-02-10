vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rioki/c9y
    REF v0.7.0
    SHA512 dd06469f745fffb4259ddcfeb79bdadc3099418db2e593f281e6006dfe9693a76ed19a64d14ad5d3c0713d9d1407402feee99b8bf756362477c7cf2084cc2c31
    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/c9y)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
