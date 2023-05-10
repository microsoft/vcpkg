vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mmahnic/argumentum
    REF "v${VERSION}"
    SHA512 3efd7950de1f05d89900a3139d2cff8c4e68250d67edd4940ad0e035e037c6fd7c5bc0dc4a5c89382f8d73313d5a8d055c04cf9a8440bc38e42e50cae323a765
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGUMENTUM_BUILD_EXAMPLES=OFF
        -DARGUMENTUM_BUILD_TESTS=OFF
        -DARGUMENTUM_BUILD_STATIC_LIBS=ON
        -DARGUMENTUM_INSTALL_HEADERONLY=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Argumentum)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
