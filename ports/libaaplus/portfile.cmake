set(VERSION 2.36)

vcpkg_download_distfile(
    ARCHIVE_FILE
    URLS "http://www.naughter.com/download/aaplus_v${VERSION}.zip"
    FILENAME "aaplus_v${VERSION}.zip"
    SHA512 a7abf20feb49df00b95be987809a3dc8df3e9ff706dd5a873ecfdd695af125f858264e092b6b856e83685e9eb46fd46520cf09dfae892c32cbb71f925ba17b86
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