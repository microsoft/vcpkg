vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/rmqcpp
    REF 52e583c2eb3f06707ce5fde7f29089b17428f6b2
    SHA512 c4232f37e7bc61d0cc77c52a1283fefc1a7925b4ef8cfbe9b404393540c773feabdc2ad3adc263beb06fe079cbf22010bf1551e15eb2f55b1347f6d8c8f35f8b
    HEAD_REF main
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
