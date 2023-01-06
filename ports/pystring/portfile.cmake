vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO imageworks/pystring
  REF v${VERSION}
  SHA512 9c0460fea67885492f9b0d29a9ba312d960fd5e43577cdcfd47faf04397ff4b7e456ed68f1948b923d2f63f9922d576b93e4ca1a27376bcb6d29c683828acb01
  HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
