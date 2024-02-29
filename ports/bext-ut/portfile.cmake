vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  boost-ext/ut
  REF
  "v${VERSION}"
  SHA512
  6894767ddae9d3ddd7aac2f77565f653e5051d213d39129a149405c6441a5f20a2878a5f548ad8d4ca37f70e44c6360c447f12df9c870149f9ed57a281214c24
  HEAD_REF
  master)

vcpkg_cmake_configure(
  SOURCE_PATH
  "${SOURCE_PATH}"
  OPTIONS
  -DBOOST_UT_ALLOW_CPM_USE=OFF
  -DBOOST_UT_BUILD_BENCHMARKS=OFF
  -DBOOST_UT_BUILD_EXAMPLES=OFF
  -DBOOST_UT_BUILD_TESTS=OFF
  -DBOOST_UT_DISABLE_MODULE=ON
  -DINCLUDE_INSTALL_DIR=include)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ut CONFIG_PATH lib/cmake/ut-${VERSION})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
     "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage"
               "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
