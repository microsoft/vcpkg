include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edenhill/librdkafka
    REF 9b3fce7b882b43302fb983d0e0e555225e672f92
    SHA512 7edda198fb10a3a005fe4f47af55940051cdb7a350b8f06e7186e70ee9f3b44c7468134f42867303184a807a274507e4fa5b2f7997cd2fd5876993de04949140
    HEAD_REF master
    PATCHES
        find_zstd.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RDKAFKA_BUILD_STATIC)

if("lz4" IN_LIST FEATURES)
    set(ENABLE_LZ4_EXT ON)
else()
    set(ENABLE_LZ4_EXT OFF)
endif()

if("ssl" IN_LIST FEATURES)
    set(WITH_SSL ON)
else()
    set(WITH_SSL OFF)
endif()

if("zlib" IN_LIST FEATURES)
    set(WITH_ZLIB ON)
else()
    set(WITH_ZLIB OFF)
endif()

if("zstd" IN_LIST FEATURES)
    set(WITH_ZSTD ON)
else()
    set(WITH_ZSTD OFF)
endif()

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/FindZstd.cmake
    DESTINATION ${SOURCE_PATH}/packaging/cmake/Modules
)

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

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/FindZstd.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/rdkafka
)

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
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
