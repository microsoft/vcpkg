vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-sqlite-2.4.0.tar.gz"
    FILENAME "libodb-sqlite-2.4.0.tar.gz"
    SHA512 af16da7c82cf8845ca3b393fbd8957a92b05ebc925a5191f20d414ab558345850073cd9c46457d0ef0edfb12ebcb27f267b934c9c69ef598380242fe920c8577
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)
file(REMOVE "${SOURCE_PATH}/version")

file(COPY
  "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
  "${CMAKE_CURRENT_LIST_DIR}/config.unix.h.in"
  DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

if(NOT VCPKG_BUILD_TYPE)
    file(READ "${CURRENT_PACKAGES_DIR}/debug/share/odb/odb_sqliteConfig-debug.cmake" LIBODB_DEBUG_TARGETS)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" LIBODB_DEBUG_TARGETS "${LIBODB_DEBUG_TARGETS}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/odb/odb_sqliteConfig-debug.cmake" "${LIBODB_DEBUG_TARGETS}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
