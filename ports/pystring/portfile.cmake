vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO imageworks/pystring
  REF v${VERSION}
  SHA512 0696553f63a2622280449b513dd9ccf92a8d7c05fad41dfa927f2bc1c3815e381348375278f7b58d932b49ea297e8b99f002c903adae49258a71120278304e84
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
