vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edenhill/librdkafka
    REF "v${VERSION}"
    SHA512 6bf1761e7ed1820b587fda24277f6606ec046da281064df13c4380f49a92f3e2b165614b9c622d46b27078ec024a4dc211610e500e597265e8219f8869c4d203
    HEAD_REF master
    PATCHES
        lz4.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RDKAFKA_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     WITH_SSL
        zlib    WITH_ZLIB
        zstd    WITH_ZSTD
        snappy  WITH_SNAPPY
        curl    WITH_CURL
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

vcpkg_cmake_config_fixup(
    PACKAGE_NAME RdKafka
    CONFIG_PATH lib/cmake/RdKafka
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
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
configure_file("${SOURCE_PATH}/LICENSES.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

# Install usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

vcpkg_fixup_pkgconfig()
