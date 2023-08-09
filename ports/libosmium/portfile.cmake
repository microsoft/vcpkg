# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF "v${VERSION}"
    SHA512 dca79a6771be759b8f1c2167d8b5981a3b5d4c6a4d6a0df5ae438c63de3f25120abfabd20a88385eeda28e287d63f2b27f2ac87301d475f3ab46111809c4b2e3
)
set(BOOST_ROOT "${CURRENT_INSTALLED_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")