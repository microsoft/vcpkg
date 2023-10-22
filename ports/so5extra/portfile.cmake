vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF "v.${VERSION}"
    SHA512 7dc632158e244ed82ec4220c022c8172cbb29fbf2176ed0899a17d655bcf047080dbaf8b35e6db666e071141bb59db140d2363eeb0e63b163988a507053c3075
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dev/so_5_extra"
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/so5extra" RENAME copyright)

