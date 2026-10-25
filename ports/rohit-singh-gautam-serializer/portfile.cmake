if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rohit-singh-gautam/Serializer
    REF d39fc06efa005bbd88896975e40309c71abe7ec1
    SHA512 1f928919d76f85178b6aec6c8fcd8e7ef0581f508ca178a46182e1f6fe20854793055d32021c0edb1d450738aa14ee816cf326dd99885a0097c956a251a5b03f
    HEAD_REF main
    PATCHES
        managed-host-generator.patch
        fix-extent-width.patch
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

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/LICENSE-RUNTIME"
    "${SOURCE_PATH}/LICENSE-GENERATED"
)
