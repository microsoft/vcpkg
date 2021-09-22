vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO timsort/cpp-TimSort
    REF v2.1.0
    SHA512 57fe79d3174d9939a3212282cf64f4fdd90586eba806f57df65eb42c2b4783a68f39bd2b6709830b1688ae15f1a83f554468059b2ddf52b31805bfd23efc7db1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gfx PACKAGE_NAME gfx-timsort)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
