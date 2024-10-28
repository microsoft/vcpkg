vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/optimizer
    REF "v${VERSION}"
    SHA512 552d6fa261c3ce2db2e0938a5b5261676335bce9bd828b46a1e2631f3b362c748ae9a6cfe7d62072fc3774b3f506bc54aa5827b52241e6f48d78a08dea1d9316
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pybind11 BUILD_ONNX_PYTHON
)
if("pybind11" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND FEATURE_OPTIONS
        -DPython3_EXECUTABLE=${PYTHON3}
        -DONNX_USE_PROTOBUF_SHARED_LIBS=ON # /wd4251
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DONNX_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
)
if("pybind11" IN_LIST FEATURES)
    # This target is not in install/export
    vcpkg_cmake_build(TARGET onnx_opt_cpp2py_export)
endif()
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME ONNXOptimizer CONFIG_PATH lib/cmake/ONNXOptimizer)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/onnxoptimizer/test"
)
