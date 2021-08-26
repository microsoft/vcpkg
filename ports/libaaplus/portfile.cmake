set(VERSION 2.12)

vcpkg_download_distfile(
    ARCHIVE_FILE
    URLS "http://www.naughter.com/download/aaplus_v${VERSION}.zip"
    FILENAME "aaplus_v${VERSION}.zip"
    SHA512 ec3a3d1346637fbed3ec5093ded821c6d80950a6432378d9826ed842571d8670cd5d2a1c9ff58a18f308e18669d786f72d24961e26bd8e070ee35674688a39e7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE_FILE}
    REF ${VERSION}
    NO_REMOVE_ONE_LEVEL
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/libaaplus)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/AA+.htm DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
