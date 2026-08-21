vcpkg_download_distfile(
    ARCHIVE_FILE
    URLS "http://www.naughter.com/download/aaplus_v${VERSION}.zip"
    FILENAME "aaplus_v${VERSION}.zip"
    SHA512 d3a134f5d4be3e1652798c7d1fec2addcf07efb631e2c681ea40553a53a56615552f71bd5b123903ad849a2959c117cc9f7fe3a1d335c613ea14f931407107d6
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE_FILE}
    SOURCE_BASE ${VERSION}
    NO_REMOVE_ONE_LEVEL
    PATCHES
        fix-cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME aaplus CONFIG_PATH share/aaplus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/AA+.htm" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
