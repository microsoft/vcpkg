#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/tclap-1.2.2")
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/tclap/tclap-1.2.2.tar.gz"
    FILENAME "tclap-1.2.2.tar.gz"
    SHA512 516ec17f82a61277922bc8c0ed66973300bf42a738847fbbd2912c6405c34f94a13e47dc964854a5b26a9a9f1f518cce682ca54e769d6016851656c647866107
)
vcpkg_extract_source_archive(${ARCHIVE})

# Copy all header files
file(COPY "${SOURCE_PATH}/include/tclap"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(COPY "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/tclap")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/tclap/COPYING" "${CURRENT_PACKAGES_DIR}/share/tclap/copyright")
