vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tmaklin/bxzstr
  REF "v${VERSION}"
  SHA512 0e9b265c817d586b66436882821c365ad4be79d87673fed995f2a7341291350e04ce65f2b3d48d397f6c5e3dd564a61fcad7b0228640a9f83533022a3552a493
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
