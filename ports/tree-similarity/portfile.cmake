vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO remz1337/tree-similarity
    REF d47aedc46011f01d37afb45e4dee1376fbb4e31b
    SHA512 33963ce5cd3d3d1131c505942d9eb461e0027287d5b9c36cf5472e4de47d46eff4fdede457f71ed7d2dcdfaead8363fffc91a868c5d84266daf441eaea617ca3
    HEAD_REF vcpkg
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
#vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tree-similarity)
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
