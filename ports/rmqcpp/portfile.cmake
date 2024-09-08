vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/rmqcpp
    REF 11859eb470f31008da522b59e96899585b4e94ce
    SHA512 f82cc1696d370e81dc410442465ecbe06940cd50ae8c93215e19a4b7de57ee7581a1d4f59d9775e08c646b63496ac18528b29edb852e0b9fb9cab7f761151b25
    HEAD_REF main
    PATCHES
      "disable-tests-and-examples.patch"
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBDE_BUILD_TARGET_CPP17=ON
    -DCMAKE_CXX_STANDARD=17
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DBDE_BUILD_TARGET_SAFE=ON
    -DCMAKE_INSTALL_LIBDIR=lib64
)

vcpkg_cmake_build()

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
