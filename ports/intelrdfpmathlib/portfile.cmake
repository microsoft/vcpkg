vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.netlib.org/misc/intel/IntelRDFPMathLib20U5.tar.gz"
    FILENAME "IntelRDFPMathLib20U5.tar.gz"
    SHA512 7c9f8cfb0eb9a83aa8806b1eb85c48a3b849ab52e75dda9703bc876b27753e09d39c7104149dccdd415746327782a989ec29c918e4f5cccb31219d72190ca4e0
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        missing-includes.patch
        fix-types.patch
)

set(LIB_SOURCE_PATH "${SOURCE_PATH}/LIBRARY")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${LIB_SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${LIB_SOURCE_PATH}"
    OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-intelrdfpmathlib
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/eula.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
