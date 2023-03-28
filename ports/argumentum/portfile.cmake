vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mmahnic/argumentum
    REF v0.3.2
    SHA512 14374d2562dcfc9b915c1008e19bf05dc442119834d6ed41fc2ba6682760d4e97ba838547143fd081167943f8564be946f35ee26b2bbeb900d9a7c9b4d9d146b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGUMENTUM_BUILD_EXAMPLES=OFF
        -DARGUMENTUM_BUILD_TESTS=OFF
        -DARGUMENTUM_BUILD_STATIC_LIBS=ON
        -DARGUMENTUM_INSTALL_HEADERONLY=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Argumentum)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
