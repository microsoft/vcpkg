vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beman-project/optional26 
    REF 90ebb59ac01cdf55289a027b10b0b7e0c2d5f18e
    SHA512 8adef74c402429757e2f06cfe7ca1eca3b9c1e8f7258a54780cd243e537cce3db294e22c26e1aa940025b4eded7596865f15dbae13f33a1a46760d718841ccb1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPTIONAL26_ENABLE_TESTING=OFF
        -DCMAKE_CXX_STANDARD=23
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# vcpkg_cmake_config_fixup(PACKAGE_NAME beman_optional26 CONFIG_PATH lib/cmake/beman_optinal26)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
