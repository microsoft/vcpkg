if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rohit-singh-gautam/Serializer
    REF 14f15f9968a06a1336a74acf3e651fa55fa9e9d8
    SHA512 8837f8a54e61d9f8f785d19b29ac5758437efd03f37915a96fb71a5b9962a76e2cedea2976432de881ad20ced05842054185f96640d19111e2858f8a0677746b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSERIALIZER_BUILD_TESTS=OFF
        -DSERIALIZER_BUILD_PROTOBUF_INTEROP_TESTS=OFF
        -DSERIALIZER_BUILD_BENCHMARKS=OFF
        -DSERIALIZER_BUILD_FUZZERS=OFF
        -DSERIALIZER_BUILD_STYLE_EXAMPLES=OFF
        -DSERIALIZER_BUILD_JAVA_EXAMPLES=OFF
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
