vcpkg_download_distfile(FIX_ASIO_PATCH
    URLS https://github.com/reo7sp/tgbot-cpp/commit/0a89870157a1f8ad546a5336bb4717f8700911d5.patch?full_index=1
    FILENAME fix-asio-error.patch
    SHA512 ac5ef3d90d2e3bce19a60e665115e93d9a28b2a1a61338c67d8d246a8c6bbc66d4336e1d871369eaf6dc6e71d332484f08a50247c78ce58e78324ee4a5fe1532
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO reo7sp/tgbot-cpp
  REF v1.7.3
  SHA512 845a051a4c7d753680759a09c1d2e1384d81f399b84d553e6785c65a6249a6a770f17eaf57ca28efd420dda78dc6c78096f045ddd87ac98a56c2c54d0b3a110b
  HEAD_REF master
  PATCHES
    ${FIX_ASIO_PATCH}
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
