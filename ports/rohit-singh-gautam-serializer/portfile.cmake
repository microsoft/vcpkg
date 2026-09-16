if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rohit-singh-gautam/Serializer
    REF 85eae1894f10cd0f0f44c724460972b817f2aff9
    SHA512 f15c08cba721171e65c22cc02d9dd7a4f793802ffae48e614e96d64a34eeb6b03b4a8dcb1df82dedfefb4d4fb19a4a1b3bc4a9b0f1462a2f261679c1248687f1
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
