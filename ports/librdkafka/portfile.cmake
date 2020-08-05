vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edenhill/librdkafka
    REF 39796d359898c07ea422849e6d7cd34cd13ec466 #v1.5.0
    SHA512 96bc1e1063d4387483f955315a8523045a308aba5fc40197c805f14ceb12ff5241f98b6937c41ab84094fe39e034e8b11ba66dd4d69a758b6ecb20d56d78cbfe
    HEAD_REF master
    PATCHES
        fix-arm64.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RDKAFKA_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    lz4     ENABLE_LZ4_EXT
    ssl     WITH_SSL
    zlib    WITH_ZLIB
    zstd    WITH_ZSTD
    snappy WITH_SNAPPY
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRDKAFKA_BUILD_STATIC=${RDKAFKA_BUILD_STATIC}
        -DRDKAFKA_BUILD_EXAMPLES=OFF
        -DRDKAFKA_BUILD_TESTS=OFF
        -DWITH_BUNDLED_SSL=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DENABLE_DEVEL=ON
        -DENABLE_REFCNT_DEBUG=ON
        -DENABLE_SHAREDPTR_DEBUG=ON
        -DWITHOUT_OPTIMIZATION=ON
    OPTIONS_RELEASE
        -DENABLE_DEVEL=OFF
        -DENABLE_REFCNT_DEBUG=OFF
        -DENABLE_SHAREDPTR_DEBUG=OFF
        -DWITHOUT_OPTIMIZATION=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/RdKafka
    TARGET_PATH share/rdkafka
)

if("lz4" IN_LIST FEATURES)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/share/rdkafka/RdKafkaConfig.cmake
        "find_dependency(LZ4)"
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/FindLZ4.cmake\")\n  find_dependency(LZ4)"
    )
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    foreach(hdr rdkafka.h rdkafkacpp.h)
        vcpkg_replace_string(
            ${CURRENT_PACKAGES_DIR}/include/librdkafka/${hdr}
            "#ifdef LIBRDKAFKA_STATICLIB"
            "#if 1 // #ifdef LIBRDKAFKA_STATICLIB"
        )
    endforeach()
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSES.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
