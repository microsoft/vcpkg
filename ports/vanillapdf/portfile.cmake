vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vanillapdf/vanillapdf
    REF "v${VERSION}"
    SHA512 f8772752338d9820b30655f8f25e625e0d345759bd33306a919be0cdf3abb247b8a7a985a88d46c1983eed233b51afac7482b79bbab3c576a5e681d9a256dcd8
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        encryption   VANILLAPDF_ENABLE_ENCRYPTION
        jpeg         VANILLAPDF_ENABLE_JPEG
        jpeg2000     VANILLAPDF_ENABLE_JPEG2000
        tests        VANILLAPDF_ENABLE_TESTS
        benchmarks   VANILLAPDF_ENABLE_BENCHMARK
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DVANILLAPDF_INTERNAL_VCPKG=OFF
      -DVANILLAPDF_ENABLE_TESTS=OFF
      -DVANILLAPDF_ENABLE_BENCHMARK=OFF
      ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# Ensure debug symbols are copied for proper installation
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "vanillapdf"
    CONFIG_PATH "lib/cmake/vanillapdf"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/NOTICE.md"
)
