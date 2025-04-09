set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/yalantinglibs
    REF "${VERSION}"
    SHA512 df45fb79713b3999ccac67228c886017bd7b4088eeb48aa2334f4861caf38d4595076149ce3c5a40858cb6cb9f1ed2588c522cc70e591e66ac19c23ab812e75b
    HEAD_REF main
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_BENCHMARK=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_UNIT_TESTS=OFF
      -DINSTALL_THIRDPARTY=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/yalantinglibs")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
