vcpkg_download_distfile(
  ARCHIVE
  URLS https://ftp.gnu.org/gnu/readline/readline-8.1.tar.gz
  FILENAME readline-8.1.tar.gz
  SHA512 27790d0461da3093a7fee6e89a51dcab5dc61928ec42e9228ab36493b17220641d5e481ea3d8fee5ee0044c70bf960f55c7d3f1a704cf6b9c42e5c269b797e00
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

file(
  COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
  DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/readline")
file(GLOB headers "${SOURCE_PATH}/*.h")
file(COPY ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include/readline")

file(
  INSTALL "${SOURCE_PATH}/COPYING"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
