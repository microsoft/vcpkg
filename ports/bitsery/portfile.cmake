vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraillt/bitsery
    REF "v${VERSION}"
    SHA512 bf43550e307713f37fb6d9c7414eeaadd16c14b791be64871c17e8fbbb0028a7818d7108edae7f29cd9522cc16606824d729220c1d018fa79f3340e8e50e5607
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
