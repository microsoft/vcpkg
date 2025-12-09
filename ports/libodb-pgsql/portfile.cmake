vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-pgsql-2.4.0.tar.gz"
    FILENAME "libodb-pgsql-2.4.0.tar.gz"
    SHA512 535515356233b815f144c0098940174f7a530e7fa4e930c0a9ebdc255fdb8bac8cdcceac31f25be4864105323e00bfe50808efa648e7c8ffb5a944e52f514b69
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)
file(REMOVE "${SOURCE_PATH}/version")

file(COPY
  "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
  "${CMAKE_CURRENT_LIST_DIR}/config.unix.h.in"
  DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME odb)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
