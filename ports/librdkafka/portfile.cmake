include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edenhill/librdkafka
    REF b25436e6325e7c941eaed1d80a3ed65b6f404e47
    SHA512 4de86fb14f932a67569cd79f924182559cb9bcc957635c36be493ec3233981755ff751982e48f6999fac50acb153f5c28a23e30538af1a2ad69af87be606a81f
    HEAD_REF master
    PATCHES
        fix-arm64.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RDKAFKA_BUILD_STATIC)

macro(check_feature _feature_name _var)
    if("${_feature_name}" IN_LIST FEATURES)
        set(${_var} ON)
    else()
        set(${_var} OFF)
    endif()
endmacro()

check_feature(lz4 ENABLE_LZ4_EXT)
check_feature(ssl WITH_SSL)
check_feature(zlib WITH_ZLIB)
check_feature(zstd WITH_ZSTD)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRDKAFKA_BUILD_STATIC=${RDKAFKA_BUILD_STATIC}
        -DRDKAFKA_BUILD_EXAMPLES=OFF
        -DRDKAFKA_BUILD_TESTS=OFF
        -DENABLE_LZ4_EXT=${ENABLE_LZ4_EXT}
        -DWITH_SSL=${WITH_SSL}
        -DWITH_BUNDLED_SSL=OFF
        -DWITH_ZLIB=${WITH_ZLIB}
        -DWITH_ZSTD=${WITH_ZSTD}
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

if(ENABLE_LZ4_EXT)
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

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME RdKafka)
