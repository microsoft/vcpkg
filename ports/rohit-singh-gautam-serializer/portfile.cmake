if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rohit-singh-gautam/Serializer
    REF 1f15cb06cf136c65855c8bce5afe05c6e3c34fd9
    SHA512 151d2757623088dfc43d49a2fc5018d35730b12de10e5078c11e1857c6d07edf36f1da1b46baa8de83406f9a080153ad5fc3cd9b4a6305276bb118cac98fbd6a
    HEAD_REF main
    PATCHES
        managed-host-generator.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        lz4 SERIALIZER_WITH_LZ4
        zlib SERIALIZER_WITH_ZLIB
        zstd SERIALIZER_WITH_ZSTD
)

set(managed_options "")
if(VCPKG_CROSSCOMPILING)
    list(APPEND managed_options
        "-DSERIALIZER_MANAGED_GENERATOR=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/serializer${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${managed_options}
        -DSERIALIZER_BUILD_MANAGED=ON
        -DSERIALIZER_BUILD_TESTS=OFF
        -DSERIALIZER_BUILD_PROTOBUF_INTEROP_TESTS=OFF
        -DSERIALIZER_BUILD_BENCHMARKS=OFF
        -DSERIALIZER_BUILD_FUZZERS=OFF
        -DSERIALIZER_BUILD_STYLE_EXAMPLES=OFF
        -DSERIALIZER_BUILD_IOSTREAM_EXAMPLES=OFF
        -DSERIALIZER_BUILD_COMPRESSION_EXAMPLES=OFF
        -DSERIALIZER_BUILD_JAVA_EXAMPLES=OFF
        -DSERIALIZER_BUILD_INTEROP_EXAMPLES=OFF
        -DSERIALIZER_BUILD_ALL_LANGUAGE_EXAMPLES=OFF
        -DSERIALIZER_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME Serializer CONFIG_PATH lib/cmake/Serializer)
vcpkg_copy_tools(TOOL_NAMES serializer AUTO_CLEAN)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/licenses"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
