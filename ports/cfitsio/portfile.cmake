include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3410.tar.gz"
    FILENAME "cfitsio3410.tar.gz"
    SHA512 b2ac31ab17e19eeeb4f1601f42f348402c0a4ab03725dbf74fe75eaabbee2f44f64f0c0ee7f0b2688bd93a9cc0dccf29f07e73b9148fff97fc78bebdbb5f6f0f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Remove duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/unistd.h)

# cfitsio uses very common names for its headers, so they must be moved to a subdirectory
file(RENAME ${CURRENT_PACKAGES_DIR}/include ${CURRENT_PACKAGES_DIR}/cfitsio)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/cfitsio ${CURRENT_PACKAGES_DIR}/include/cfitsio)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # move DLLs to bin directories for dynamic builds
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME  ${CURRENT_PACKAGES_DIR}/lib/cfitsio.dll ${CURRENT_PACKAGES_DIR}/bin/cfitsio.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME  ${CURRENT_PACKAGES_DIR}/debug/lib/cfitsio.dll ${CURRENT_PACKAGES_DIR}/debug/bin/cfitsio.dll)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cfitsio RENAME copyright)
