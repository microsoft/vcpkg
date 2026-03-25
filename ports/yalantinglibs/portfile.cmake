set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/yalantinglibs
    REF "${VERSION}"
    SHA512 1cebf45571849d1eed652e0d2a151b126e706bbfe232ecddb6e8f7f4dcd35806ce692629208b773ebeec3a0c74ee98121d4a24f7452db1b835fd5340adc66b9c
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
