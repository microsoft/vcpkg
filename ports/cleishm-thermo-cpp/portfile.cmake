vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/thermo-cpp
    REF "v${VERSION}"
    SHA512 25e71945580c35b9161cba6a8c9c84f4473b17bd258fc95c18c99f0bd7fb9fcd11a40ce70404cec0a6823f7989af374789b14f5bc6588fc82f374fd4a105fa87
    HEAD_REF main
    PATCHES
        001-fix-flags.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTHERMO_BUILD_TESTS=OFF
        -DTHERMO_BUILD_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME thermo CONFIG_PATH lib/cmake/thermo)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
