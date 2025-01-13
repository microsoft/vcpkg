vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/onnx
    REF "v${VERSION}"
    SHA512 7a9a8493b9c007429629484156487395044506f34e72253640e626351cb623b390750b36af78a290786131e3dcac35f4eb269e8693b594b7ce7cb105bcf9318d
    PATCHES
        fix-cmakelists.patch
        fix-dependency-protobuf.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)

# ONNX_USE_PROTOBUF_SHARED_LIBS: find the library and check its file extension
find_library(PROTOBUF_LIBPATH NAMES protobuf PATHS "${CURRENT_INSTALLED_DIR}/bin" "${CURRENT_INSTALLED_DIR}/lib" REQUIRED)
get_filename_component(PROTOBUF_LIBNAME "${PROTOBUF_LIBPATH}" NAME)
if(PROTOBUF_LIBNAME MATCHES "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(USE_PROTOBUF_SHARED ON)
else()
    set(USE_PROTOBUF_SHARED OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pybind11 BUILD_ONNX_PYTHON
)

# Like protoc, python is required for codegen.
if("pybind11" IN_LIST FEATURES)
    x_vcpkg_get_python_packages(PYTHON_VERSION 3
        REQUIREMENTS_FILE "${SOURCE_PATH}/requirements-min.txt"
        PACKAGES "pybind11"
        OUT_PYTHON_VAR PYTHON3
    )
    execute_process(
        COMMAND "${PYTHON3}" -c "import site; print(site.getsitepackages()[0])"
        OUTPUT_VARIABLE SITE_PACKAGES_DIR OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    find_path(pybind11_DIR NAMES pybind11Config.cmake PATHS "${SITE_PACKAGES_DIR}" "${SITE_PACKAGES_DIR}/Lib/site-packages" PATH_SUFFIXES "pybind11/share/cmake/pybind11" REQUIRED NO_DEFAULT_PATH)
    list(APPEND FEATURE_OPTIONS "-Dpybind11_DIR:PATH=${pybind11_DIR}")
else()
    vcpkg_find_acquire_program(PYTHON3)
endif()

# PATH for .bat scripts so it can find 'python'
get_filename_component(PYTHON_DIR "${PYTHON3}" PATH)
vcpkg_add_to_path(PREPEND "${PYTHON_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPython3_EXECUTABLE=${PYTHON3}"
        -DONNX_ML=ON
        -DONNX_GEN_PB_TYPE_STUBS=ON
        -DONNX_USE_PROTOBUF_SHARED_LIBS=${USE_PROTOBUF_SHARED}
        -DONNX_USE_LITE_PROTO=OFF
        -DONNX_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DONNX_BUILD_TESTS=OFF
        -DONNX_BUILD_BENCHMARKS=OFF
    MAYBE_UNUSED_VARIABLES
        ONNX_USE_MSVC_STATIC_RUNTIME
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ONNX PACKAGE_NAME ONNX)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    # the others are empty
    "${CURRENT_PACKAGES_DIR}/include/onnx/backend"
    "${CURRENT_PACKAGES_DIR}/include/onnx/bin"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/controlflow"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/generator"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/image"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/logical"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/math"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/nn"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/object_detection"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/optional"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/quantization"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/reduction"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/rnn"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/sequence"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/text"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/traditionalml"
    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/training"
    "${CURRENT_PACKAGES_DIR}/include/onnx/examples"
    "${CURRENT_PACKAGES_DIR}/include/onnx/frontend"
    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_cpp2py_export"
    "${CURRENT_PACKAGES_DIR}/include/onnx/test"
    "${CURRENT_PACKAGES_DIR}/include/onnx/tools"
    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_ml"
    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_data"
    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_operators_ml"
    "${CURRENT_PACKAGES_DIR}/include/onnx/reference/ops"
    "${CURRENT_PACKAGES_DIR}/include/onnx/reference"
)
