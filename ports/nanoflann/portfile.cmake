vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF v1.4.2
    SHA512 2a400725940868473d376635f67aac4402046d771ecceec547442dd653f0a00e38e340e4ac0a98620ddf3927845df18b6cfd644982f073d26c7864bed2de96ca
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOFLANN_BUILD_EXAMPLES=OFF
        -DNANOFLANN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/${PORT}/cmake")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
