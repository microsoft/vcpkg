vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO confluentinc/librdkafka
    REF "v${VERSION}"
    SHA512 2e4d13d601ea1894edcace2051aa4284ba17306d3f19971734f05d0fcef413b29961b3f701da1b6517e23930bd53034c75ee25c696ac1da7e6b7051cc8ed61eb
    HEAD_REF master
    PATCHES
        lz4.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RDKAFKA_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl    WITH_CURL
        sasl    WITH_SASL
        sasl    WITH_SASL_CYRUS
        ssl     WITH_SSL
        ssl     WITH_SASL_OAUTHBEARER
        ssl     WITH_SASL_SCRAM
        zlib    WITH_ZLIB
        zstd    WITH_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRDKAFKA_BUILD_STATIC=${RDKAFKA_BUILD_STATIC}
        -DRDKAFKA_BUILD_EXAMPLES=OFF
        -DRDKAFKA_BUILD_TESTS=OFF
        -DWITH_BUNDLED_SSL=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DENABLE_SHAREDPTR_DEBUG=ON
        -DENABLE_DEVEL=ON
        -DENABLE_REFCNT_DEBUG=OFF
        -DENABLE_SHAREDPTR_DEBUG=ON
        -DWITHOUT_OPTIMIZATION=ON
    OPTIONS_RELEASE
        -DENABLE_SHAREDPTR_DEBUG=OFF
        -DENABLE_DEVEL=OFF
        -DENABLE_REFCNT_DEBUG=OFF
        -DENABLE_SHAREDPTR_DEBUG=OFF
        -DWITHOUT_OPTIMIZATION=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/RdKafka" PACKAGE_NAME "rdkafka")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/rdkafka/FindLZ4.cmake"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    foreach(hdr rdkafka.h rdkafkacpp.h)
        vcpkg_replace_string(
            "${CURRENT_PACKAGES_DIR}/include/librdkafka/${hdr}"
            "#ifdef LIBRDKAFKA_STATICLIB"
            "#if 1 // #ifdef LIBRDKAFKA_STATICLIB"
        )
    endforeach()
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES.txt" )

# Install usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

vcpkg_fixup_pkgconfig()
