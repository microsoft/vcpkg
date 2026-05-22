vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO imageworks/pystring
  REF v${VERSION}
  SHA512 519c63cd46ff7b4394b9c94c4f8d2eccceafd06fe8d034de9ee43ffad80bd57fc1a40c77672753609d386fbe4fa8b9d62211a9a874f74457e1c699cd0a318b08
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
