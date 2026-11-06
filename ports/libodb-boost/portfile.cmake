vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-boost-2.4.0.tar.gz"
    FILENAME "libodb-boost-2.4.0.tar.gz"
    SHA512 af716b0385cf4ea18b20dcd5880c69c43cfc195eec4ff196a8e438833306489c39ab06a494e5d60cd08ba0d94caa05bd07e5f3fa836d835bad15c8a2ad7de306
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)
file(REMOVE "${SOURCE_PATH}/version")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h" DESTINATION "${SOURCE_PATH}/odb/boost/details")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(NOT VCPKG_BUILD_TYPE)
    file(READ "${CURRENT_PACKAGES_DIR}/debug/share/odb/odb_boostConfig-debug.cmake" LIBODB_DEBUG_TARGETS)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" LIBODB_DEBUG_TARGETS "${LIBODB_DEBUG_TARGETS}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/odb/odb_boostConfig-debug.cmake" "${LIBODB_DEBUG_TARGETS}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
