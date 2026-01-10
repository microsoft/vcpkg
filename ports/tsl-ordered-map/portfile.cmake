vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/ordered-map
    REF "v${VERSION}"
    SHA512 19076fd40e0a4baad58a5cc6f9c906f38167e6c5474e461e982d0e0ea2adeb21fa8acf669145ac033338bf53cc3dc178782d54a9bcf7f835a62b07983da00253
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright
)
