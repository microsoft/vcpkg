vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kthohr/gcem
    REF v1.16.0
    SHA512 72b2c2022eabe30607533aee4cc7786646fad4d78733f34383dacf7da9298de40e77b3e3f62b5785fd3821387756858bddc94b16dc918fe5d4778e283ae635be
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gcem)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
