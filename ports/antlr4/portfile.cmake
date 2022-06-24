set(VERSION 4.10.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.antlr.org/download/antlr4-cpp-runtime-${VERSION}-source.zip"
    FILENAME "antlr4-cpp-runtime-${VERSION}-source.zip"
    SHA512 f4926987946d17bf51b2d8a31ac06cf16eea7fb49ce535abb2d4759c9e6113d173c4504ffe4c8d2f9a58d845507dfdedaaba3dde70cc09c03c6bd6a2afe892a6
)

# license not exist in antlr folder.
vcpkg_download_distfile(LICENSE
    URLS https://raw.githubusercontent.com/antlr/antlr4/${VERSION}/LICENSE.txt
    FILENAME "antlr4-copyright-${VERSION}"
    SHA512 1e8414de5fdc211e3188a8ec3276c6b3c55235f5edaf48522045ae18fa79fd9049719cb8924d25145016f223ac9a178defada1eeb983ccff598a08b0c0f67a3b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    REF ${VERSION}
    PATCHES
        fixed_build.patch
        uuid_discovery_fix.patch
        fix_LNK2001.patch #The related upstream issue https://github.com/antlr/antlr4/issues/3674 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DANTLR4_INSTALL=ON
        -DANTLR_BUILD_CPP_TESTS=OFF
    OPTIONS_DEBUG -DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/dist
    OPTIONS_RELEASE -DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dist
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-generator CONFIG_PATH lib/cmake/antlr4-generator DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-runtime CONFIG_PATH lib/cmake/antlr4-runtime)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${LICENSE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
