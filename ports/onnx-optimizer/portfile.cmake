vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/optimizer
    REF "v${VERSION}"
    SHA512 831bcfca85d4a84b8dffd6cf6e061e6a9b67d14b56a1b8a4fadd9a9a2ce7c17f1488d39d97bf8c3d6a5e5f9ea02de2d56e5ed8e45a52e33f263ecd22b453a068
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") 
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/onnxoptimizer/test"
)
