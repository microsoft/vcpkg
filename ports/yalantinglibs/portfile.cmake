set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/yalantinglibs
    REF "${VERSION}"
    SHA512 df0aafbda3abf7bd4d2432aa5edede8ce9603f21ad2c1c126759253fcf7394550e74e81b87ed7db4fbc59e6e6e5ba92f552bbce8e772482765cea0a71ecffd89
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
