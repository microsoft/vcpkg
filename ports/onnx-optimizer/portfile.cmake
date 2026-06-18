vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/optimizer
    REF "v${VERSION}"
    SHA512 ed9844c3ff30406e28dd06fe8a2ed202f301aacdc2c489b5a77dfa7ce6f33647939a00a059a47a5d474797aca6396ceb28c403d4054ff3714c2f6388a34279bf
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DONNX_OPT_USE_SYSTEM_PROTOBUF=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ONNXOptimizer CONFIG_PATH lib/cmake/ONNXOptimizer)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/onnxoptimizer/test"
)
