vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BobSteagall/wg21
    REF "v${VERSION}"
    SHA512 ab1db0cff476d2f63a5d1fcc1d3b40acbceeacae61a99d7ad0b8d8abe21413da97b71c088a331b70c0d0c3dc4615953485c68af46698ec7f0013e14bea5f9452
    PATCHES
        use-external-mdspan.patch # https://github.com/BobSteagall/wg21/pull/80
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLA_INSTALL=ON
        -DLA_BUILD_PACKAGE=OFF
        -DLA_ENABLE_TESTS=OFF
        -DUSE_EXTERNAL_MDSPAN=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME wg21_linear_algebra
    CONFIG_PATH lib/cmake/wg21_linear_algebra
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/cmake"
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)
