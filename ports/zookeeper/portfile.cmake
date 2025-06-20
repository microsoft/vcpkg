vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REGEX REPLACE "^([0-9]+[.][0-9]+[.][0-9]+)[.]([0-9]+)\$" "\\1-\\2" VERSION "${VERSION}")

vcpkg_download_distfile(
    zookeeper_src_archive
    URLS "https://dlcdn.apache.org/zookeeper/stable/apache-zookeeper-${VERSION}.tar.gz"
    FILENAME "apache-zookeeper-${VERSION}.tar.gz"
    SHA512 78d909c92b3709cc2112d1b8df9ef006f78a81ee0aa1b6b6400b8fea771ebaafc03cde497c6080e3fd924b75facb28420c4970885914e5dc9cd47cd761e96dd4
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${zookeeper_src_archive}"
    PATCHES
        cmake.patch
        win32.patch
)
file(COPY "${CURRENT_PORT_DIR}/unofficial-zookeeperConfig.cmake" DESTINATION "${SOURCE_PATH}/zookeeper-client/zookeeper-client-c")

# We must run the jute generator which is made from Java sources.
# We fetch it as JAR from the latest matching binary release of zookeeper.
vcpkg_download_distfile(
    zookeeper_bin_archive
    URLS "https://dlcdn.apache.org/zookeeper/stable/apache-zookeeper-${VERSION}-bin.tar.gz"
    FILENAME "apache-zookeeper-${VERSION}-bin.tar.gz"
    SHA512 4d85d6f7644d5f36d9c4d65e78bd662ab35ebe1380d762c24c12b98af029027eee453437c9245dbdf2b9beb77cd6b690b69e26f91cf9d11b0a183a979c73fa43
)
vcpkg_extract_source_archive(
    zookeeper_jute_path
    ARCHIVE "${zookeeper_bin_archive}"
)
string(APPEND zookeeper_jute_path "/lib/zookeeper-jute-${VERSION}.jar")

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
