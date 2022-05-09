vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6.tar.gz"
    FILENAME "zookeeper-3.5.6.tar.gz"
    SHA512 7f45817cbbc42aec5a7817fa2ae99656128e666dc58ace23d86bcfc5ca0dc49e418d1a7d1f082ad80ccb916f9f1b490167d16f836886af1a56fbcf720ad3b9d0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        cmake.patch
        win32.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sync WANT_SYNCAPI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DWANT_CPPUNIT=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
