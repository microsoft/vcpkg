vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://gamma.cs.unc.edu/software/downloads/SSV/pqp-1.3.tar.gz"
    FILENAME "pqp-1.3.tar.gz"
    SHA512 baad7b050b13a6d13de5110cdec443048a3543b65b0d3b30d1b5f737b46715052661f762ef71345d39978c0c788a30a3a935717664806b4729722ee3594ebdc1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-math-functions.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
