vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REGEX REPLACE "^([0-9]+[.][0-9]+[.][0-9]+)[.]([0-9]+)\$" "\\1-\\2" VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/zookeeper
    REF "release-${VERSION}"
    SHA512 98e42f35dd369e322439d87d0f7da13b78eaeb092f259c0eca9e5bd4971e297b9bbf5a3292b4f9e4e5a5f5f7f4e637774f175d0d68fcc07c9733471ba9d9ba1b
    HEAD_REF master
    PATCHES
        cmake.patch
        win32.patch
)
file(COPY "${CURRENT_PORT_DIR}/unofficial-zookeeperConfig.cmake" DESTINATION "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c")

# We must run the jute generator which is made from Java sources.
# We fetch it as JAR from the latest matching binary release of zookeeper.
string(REPLACE "3.9.4-0" "3.9.3" jute_release "${VERSION}")
vcpkg_download_distfile(
    zookeeper_bin_archive
    URLS "https://dlcdn.apache.org/zookeeper/zookeeper-${jute_release}/apache-zookeeper-${jute_release}-bin.tar.gz"
    FILENAME "apache-zookeeper-${jute_release}-bin.tar.gz"
    SHA512 d44d870c1691662efbf1a8baf1859c901b820dc5ff163b36e81beb27b6fbf3cd31b5f1f075697edaaf6d3e7a4cb0cc92f924dcff64b294ef13d535589bdaf143
)
vcpkg_extract_source_archive(
    zookeeper_jute_path
    ARCHIVE "${zookeeper_bin_archive}"
)
string(APPEND zookeeper_jute_path "/lib/zookeeper-jute-${jute_release}.jar")

block(SCOPE_FOR VARIABLES)
    # Do not warn about FindJava.cmake accessing WIN32
    set(Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL "TRACE")
    set(WIN32 "${CMAKE_HOST_WIN32}")
    find_package(Java COMPONENTS Runtime REQUIRED)

    # cf. zookeeper-jute/pom.xml > "generate-C-Jute"
    file(MAKE_DIRECTORY "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c/generated")
    vcpkg_execute_required_process(
        COMMAND "${Java_JAVA_EXECUTABLE}"
            -classpath "${zookeeper_jute_path}"
            org.apache.jute.compiler.generated.Rcc
            -l c
            "${SOURCE_PATH}/zookeeper-jute/src/main/resources/zookeeper.jute"
        WORKING_DIRECTORY "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c/generated"
        LOGNAME "generate-C-Jute"
    )
endblock()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl WITH_OPENSSL
        openssl VCPKG_LOCK_FIND_PACKAGE_OpenSSL
        sync    WANT_SYNCAPI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c"
    OPTIONS
        -DTHREADS_PREFER_PTHREAD_FLAG=ON
        -DWANT_CPPUNIT=OFF
        -DWITH_CYRUS_SASL=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        THREADS_PREFER_PTHREAD_FLAG
        VCPKG_LOCK_FIND_PACKAGE_OpenSSL
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-zookeeper)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c/LICENSE")
