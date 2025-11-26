set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/yalantinglibs
    REF "${VERSION}"
    SHA512 7da5b6826526f01768deed76c323f03c666f6b91f65c0719c0a7d9991cc8e779337bf341ef3b0ec43d1a3f98cecfc0f09d0fe420bd7f546cdad856e69e64f4f6
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
