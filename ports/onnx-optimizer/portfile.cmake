vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/optimizer
    REF v0.2.6
    SHA512 cc6373781f04bc6fafd3282d248e26eaf93556b86acbb0dee44b4aa7a5d59c634905c1a05d035e31a50fc0f06cfc686fa483b79a324dd973faa421747d4a681b
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
)

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
)
if("pybind11" IN_LIST FEATURES)
    # This target is not in install/export
    vcpkg_cmake_build(TARGET onnx_opt_cpp2py_export)
endif()
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME ONNXOptimizer CONFIG_PATH lib/cmake/ONNXOptimizer)

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/onnxoptimizer/test"
)
