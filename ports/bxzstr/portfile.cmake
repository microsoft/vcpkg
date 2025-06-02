vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tmaklin/bxzstr
  REF "v${VERSION}"
  SHA512 8ea73cc531be6b75cddc0ac3d633df5f0b647c61b57e788052273efa8ab3bb9c23760156db8876ab0d7d48e067af2ed49bd3aa8644b4e8ea518be84a284b2ef4
  HEAD_REF master
)

file(INSTALL
     "${SOURCE_PATH}/include/bxzstr.hpp"
     "${SOURCE_PATH}/include/bz_stream_wrapper.hpp"
     "${SOURCE_PATH}/include/compression_types.hpp"
     "${SOURCE_PATH}/include/config.hpp"
     "${SOURCE_PATH}/include/lzma_stream_wrapper.hpp"
     "${SOURCE_PATH}/include/stream_wrapper.hpp"
     "${SOURCE_PATH}/include/strict_fstream.hpp"
     "${SOURCE_PATH}/include/z_stream_wrapper.hpp"
     "${SOURCE_PATH}/include/zstd_stream_wrapper.hpp"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include/bxzstr")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
