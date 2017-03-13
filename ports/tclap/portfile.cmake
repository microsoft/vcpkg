#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/tclap-1.2.1")
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/tclap/tclap-1.2.1.tar.gz"
    FILENAME "tclap-1.2.1.tar.gz"
    SHA512 8bd6ee724600880840048c7b36f02d31b1aa4910b17f80fb04aef89b1f1917856d9979ec488edbd457b66d9d689aea97540abb842a8b902bbd75c66a6e07b9b1
)
vcpkg_extract_source_archive(${ARCHIVE})

# Copy all header files
file(COPY "${SOURCE_PATH}/include/tclap"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(COPY "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/tclap")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/tclap/COPYING" "${CURRENT_PACKAGES_DIR}/share/tclap/copyright")
