include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "WindowsStore not supported")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VERSION 1.1.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://cmocka.org/files/1.1/cmocka-${VERSION}.tar.xz"
    FILENAME "cmocka-${VERSION}.tar.xz"
    SHA512 b1a2ce72234256d653eebf95f8744a34525b9027e1ecf6552e1620c83a4bdda8b5674b748cc5fd14abada1e374829e2e7f0bcab0b1c8d6c3b7d9b7ec474b6ed3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Move cmake files to expected directory tree
file(COPY DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/cmake/cmocka
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmocka
     FILES_MATCHING PATTERN "*.cmake" )
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cmocka/cmocka
     ${CURRENT_PACKAGES_DIR}/share/cmocka/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

# Remove duplicated files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Install license file as copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmocka RENAME copyright)
