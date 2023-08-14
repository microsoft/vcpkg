vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/ade
    REF v0.1.2
    SHA512 2761cf9ccb92d1df6f2d61964a64085470fff78b92d040fd8411d4c3a1f238b95eb4484a9624ab800e8fb4e5144eea32dee9a9047b9b67fad83d0856d32c91e9
    HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS_DEBUG
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
