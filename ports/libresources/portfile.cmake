vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO as-shura/libresources
    REF 1a1189f6d4b7c2c0c8037d3c0e2456f1db3b80b7
    SHA512 80ac46a7c1bda29abada2f995afb5c68fa0bda55e57d46f3fff247ee6bc8442761afd88306f22bd5b75a45fb0ed5958fbfc9774ecf0fd9dac59ad0b1aef4e39c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME libresources CONFIG_PATH lib/cmake/libresources)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)



