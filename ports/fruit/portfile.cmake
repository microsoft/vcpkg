
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/fruit
    REF 29c9fd265cfa72ee72fb64257fe4b72198d87264 # v3.6.0
    SHA512 1a8f5b126492dd81fe40bbedd0ead839fd25dac6ea569dd51879e288a4c5850c6618754547ac201d82875781ee0490261372df7a0d1cf50e90c3a9b9da9aaed4
    HEAD_REF master
)

# TODO: Make boost an optional dependency?
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFRUIT_USES_BOOST=False
        -DFRUIT_TESTS_USE_PRECOMPILED_HEADERS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
