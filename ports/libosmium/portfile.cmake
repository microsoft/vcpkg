# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF b263ba5e85c9ac254fa4090c855ec6f0556795e2 #v2.17.0
    SHA512 fd2955af6153ef58d76cca1e5b83cb70cd33cb616a3e221a80df94ee1256eeeaa5f15f4727cd1023f0335e55d7f3f36e3f9f5490bcd78ba9d267b2075480d1ba
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