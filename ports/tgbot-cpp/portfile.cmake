vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO reo7sp/tgbot-cpp
  REF v1.7.3
  SHA512 845a051a4c7d753680759a09c1d2e1384d81f399b84d553e6785c65a6249a6a770f17eaf57ca28efd420dda78dc6c78096f045ddd87ac98a56c2c54d0b3a110b
  HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)
