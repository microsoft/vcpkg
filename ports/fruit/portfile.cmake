
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/fruit
    REF v3.7.0
    SHA512 6a18f2740fc52672de49f082b5a21d0a236520da83e77806935baca5d5a0b41f75f1d1b6729cad13fc77b0f033d7d8d2158fd58b1e565a7662bd80dc7eb63ba1
    HEAD_REF master
)

# TODO: Make boost an optional dependency?
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFRUIT_USES_BOOST=False
        -DFRUIT_TESTS_USE_PRECOMPILED_HEADERS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
