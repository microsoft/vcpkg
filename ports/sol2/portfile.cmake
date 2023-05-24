vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF eba86625b707e3c8c99bbfc4624e51f42dc9e561 #v3.3.0
    SHA512 a1fbcb4efd9a8b8b97c351e90499644aea72a3db62c258e219a2912853936b76870b51e69d835c14cbf1a20733673ba474e259a0243fec419c411b995cd1511d 
    HEAD_REF develop
    PATCHES fix-namespace.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sol2)

file(
    REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug"
        "${CURRENT_PACKAGES_DIR}/lib"
        "${CURRENT_PACKAGES_DIR}/include"
)

file(INSTALL "${SOURCE_PATH}/include/sol" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
