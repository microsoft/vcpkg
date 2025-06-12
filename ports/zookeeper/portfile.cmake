vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3.tar.gz"
    FILENAME "zookeeper-3.9.3.tar.gz"
    SHA512 7a8ffdc9e48f6e293ee5fde0dee73ffcdd1a4f1e554b4282ce403ffb09ff145b40987c272dec751993a83a5430972e0a535d18fa9818d6c84a69bfda8a03d216
)

vcpkg_extract_source_archive(
    SOURCE_PATH
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
