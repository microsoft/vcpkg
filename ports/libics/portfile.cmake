vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF "${VERSION}"
    SHA512 290d6d7bd3f5611d0b46aa6406ef10449ee768bc14d0b34f0bb365ca46f98b7fd4065c94fd9594e357427a4d0644f2724a1f773c7f3b43adc3db2389b94ee88e
    HEAD_REF master
    PATCHES fix-integral-include.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/GNU_LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
