# uwp: LOAD_LIBRARY_SEARCH_DEFAULT_DIRS undefined identifier
vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/onnx
    REF v1.9.0
    SHA512 a3eecc74ce4f22524603fb86367d21c87a143ba27eef93ef4bd2e2868c2cadeb724b84df58a429286e7824adebdeba7fa059095b7ab29df8dcea8777bd7f4101
    PATCHES
        fix-cmakelists.patch
)
# ONNXIFI sources will be replaced with https://github.com/houseroad/foxi
if("foxi" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH FOXI_SOURCE_PATH
        REPO houseroad/foxi
        REF c278588e34e535f0bb8f00df3880d26928038cad
        HEAD_REF master
        SHA512 ad42cfd70e40ba0f0a9187b34ae9e3bd361c8c0038669f4c1591c4f7421d12ad93f76f42b33c2575eea1a3ddb3ff781da2895cdc636df5b60422598f450203c7
        PATCHES
            fix-foxi-sources.patch
    )
    file(COPY "${FOXI_SOURCE_PATH}/foxi/onnxifi_dummy.c"    DESTINATION "${SOURCE_PATH}/onnx")
    file(COPY "${FOXI_SOURCE_PATH}/foxi/onnxifi_ext.h"      DESTINATION "${SOURCE_PATH}/onnx")
    file(COPY "${FOXI_SOURCE_PATH}/foxi/onnxifi_loader.c"   DESTINATION "${SOURCE_PATH}/onnx")
    file(COPY "${FOXI_SOURCE_PATH}/foxi/onnxifi_loader.h"   DESTINATION "${SOURCE_PATH}/onnx")
    file(COPY "${FOXI_SOURCE_PATH}/foxi/onnxifi_wrapper.c"  DESTINATION "${SOURCE_PATH}/onnx")
    file(COPY "${FOXI_SOURCE_PATH}/foxi/onnxifi.h"          DESTINATION "${SOURCE_PATH}/onnx")
    file(INSTALL "${FOXI_SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright.foxi)
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)

# ONNX_USE_PROTOBUF_SHARED_LIBS: find the library and check its file extension
find_library(PROTOBUF_LIBPATH NAMES protobuf PATHS ${CURRENT_INSTALLED_DIR}/bin ${CURRENT_INSTALLED_DIR}/lib REQUIRED)
get_filename_component(PROTOBUF_LIBNAME ${PROTOBUF_LIBPATH} NAME)
if(PROTOBUF_LIBNAME MATCHES ${CMAKE_SHARED_LIBRARY_SUFFIX})
    set(USE_PROTOBUF_SHARED ON)
else()
    set(USE_PROTOBUF_SHARED OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pybind11      BUILD_ONNX_PYTHON
        protobuf-lite ONNX_USE_LITE_PROTO
)

# Like protoc, python is required for codegen.
vcpkg_find_acquire_program(PYTHON3)

# PATH for .bat scripts so it can find 'python'
get_filename_component(PYTHON_DIR ${PYTHON3} PATH)
vcpkg_add_to_path(PREPEND ${PYTHON_DIR})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPython3_EXECUTABLE=${PYTHON3}
        -DONNX_ML=ON
        -DONNX_GEN_PB_TYPE_STUBS=ON
        -DONNX_USE_PROTOBUF_SHARED_LIBS=${USE_PROTOBUF_SHARED}
        -DONNX_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DONNX_BUILD_TESTS=OFF
        -DONNX_BUILD_BENCHMARKS=OFF
    MAYBE_UNUSED_VARIABLES
        ONNX_USE_MSVC_STATIC_RUNTIME
)

if("pybind11" IN_LIST FEATURES)
    # This target is not in install/export
    vcpkg_cmake_build(TARGET onnx_cpp2py_export)
endif()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ONNX)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    # the others are empty
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_ml"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_data"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_operators_ml"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_cpp2py_export"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/backend"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/tools"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/test"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/bin"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/examples"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/frontend"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/controlflow"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/generator"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/logical"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/math"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/nn"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/object_detection"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/quantization"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/reduction"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/rnn"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/sequence"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/traditionalml"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/training"
)
