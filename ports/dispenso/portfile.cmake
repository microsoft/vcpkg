vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/dispenso
    REF "v${VERSION}"
    SHA512 6d21b7d066903d7489b6dd166efb38b9bc2ba1f995f3f52c9ffe9f088d6fd64108bf6442008bc3446ffb864e7f026b9fb3861d78796454615730411c6a316aa5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISPENSO_BUILD_TESTS=OFF
        -DDISPENSO_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()

# CMake config is installed to lib/cmake/Dispenso-${VERSION}
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Dispenso-${VERSION}")

# Remove debug share directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Remove duplicate include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
