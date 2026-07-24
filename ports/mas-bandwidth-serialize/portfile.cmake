# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/serialize
    REF "v${VERSION}"
    SHA512 b08a98594a63a14783e1e540c6555c414fcea06aa7064def63eb59b783391c3dbfd7f0b0d985fa8f2b0f97051add3a0c12d8f128dbd4ac2f89f15c745f57dc26
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSERIALIZE_BUILD_TESTS=OFF
        -DSERIALIZE_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME serialize CONFIG_PATH lib/cmake/serialize)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
