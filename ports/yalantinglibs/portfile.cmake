set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/yalantinglibs
    REF "${VERSION}"
    SHA512 4431c4fea7af80b81b35989879d47ad09abca31789f8e5bc77aae85824b1bd7c6d3de57c5421820670cbdd2313dbc9ea56ad8bf3f4dc8751d51d9ce7212985b0
    HEAD_REF main
    PATCHES
        use-external-libs.patch
)

# Remove the vendored iguana and cinatra sources
file(REMOVE_RECURSE "${SOURCE_PATH}/include/ylt/standalone")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_BENCHMARK=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_UNIT_TESTS=OFF
      -DINSTALL_THIRDPARTY=OFF
      -DINSTALL_STANDALONE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/yalantinglibs")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
