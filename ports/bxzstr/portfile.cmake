vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tmaklin/bxzstr
  REF "v${VERSION}"
  SHA512 1d957ed42d62aa7deddabd862805c80273aedacda5b1fad867df6d0c8cfeab69557d87830934f70f70a52acd8e251ad0e47178a70f9fe34713b28c6ff91f2d87
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
