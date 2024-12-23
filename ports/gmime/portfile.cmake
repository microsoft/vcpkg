set(LIB_NAME gmime)
set(LIB_VERSION 3.2.6)

set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gmime/3.2/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 a60d3f9f1aa8490865c22cd9539544e9c9f3ceb4037b9749cf9e5c279f97aa88fc4cd077bf2aff314ba0db2a1b7bbe76f9b1ca5a17fffcbd6315ecebc5414a3d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${LIB_VERSION}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

# We can use file supplied with original sources
if(VCPKG_TARGET_IS_WINDOWS)
    configure_file("${SOURCE_PATH}/build/vs2017/unistd.h" "${SOURCE_PATH}" COPYONLY)
    configure_file("${SOURCE_PATH}/build/vs2017/config.h" "${SOURCE_PATH}" COPYONLY)
    configure_file("${SOURCE_PATH}/build/vs2017/gmime.def" "${SOURCE_PATH}" COPYONLY)
else()
    configure_file(${CMAKE_CURRENT_LIST_DIR}/config-linux.h "${SOURCE_PATH}/config.h" COPYONLY)
endif()


vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# License and man
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${LIB_NAME}" RENAME copyright)

vcpkg_copy_pdbs()
