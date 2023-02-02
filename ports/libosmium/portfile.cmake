# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF v2.18.0
    SHA512 bfe4d5b08e284abb21280205437c62d260948c8585cc8d10f0c3496fd29df1ff6c6bc436283207f292d6a8af911835ebef64403c3fde2a262b55fde5296c13ce
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