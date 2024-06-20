vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO niekbouman/ctbignum
    REF cf3233d8b7dcff59f29a7389204959ee2228a4af
    SHA512 8cd5e187836f48165a088a171c87ce438393e66f7362af1b67a253ae6ef0b17c41468e21e0dfe337094796f2b2a2fa5062cc9a9231afc377f187baf1ead1257e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
       -DCTBIGNUM_BuildTests=OFF
       -DCTBIGNUM_BuildBenchmarks=OFF
)

vcpkg_cmake_install()

# Move CMake files to the right place
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
# Remove empty files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

