vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tmaklin/bxzstr
  REF "v${VERSION}"
  SHA512 e357eb99b007031a1b15b20077883ebb20b294fda97d4aa354ded04c8d0b398fdeae9e1e97747caf55699a8feadf8c10eb807a9c6a66837a0816002df34fb7a1
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
