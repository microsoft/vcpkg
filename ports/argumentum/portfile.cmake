vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mmahnic/argumentum
    REF v0.2.2
    SHA512 750a26d021cdf243479a20d01924007cdca717a53f34e4969d2df6c2c10c2f41a4df4bcd0a9fdf3d75928290d31195fa490fe13d4f2cba391c9dbad48aa98184
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DARGUMENTUM_BUILD_EXAMPLES=OFF
        -DARGUMENTUM_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Argumentum)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)
