set(LIB_VERSION 20200926)
set(LIB_FILENAME libvmdk-alpha-${LIB_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libvmdk/releases/download/${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 e70c42580dc58ad0a6459fe461504a8ef128f8d5df9d500f84f316e627232606f22eb4906fc1debc3e75e71daa6a07951af80822695de13d5e466adda4cfd5e0
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${LIB_VERSION}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libvmdk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
