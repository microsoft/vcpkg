vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/onnx
    REF "v${VERSION}"
    SHA512 7b59ca1a42d3ca177a75e78d913c9fc4f6b80f167496b9416932289750f46c6999b02f4270fe7701917a494306bd84148f6d9d6cdaa0ca4f068d994ddd3076ab
    PATCHES
        fix-cmakelists.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)

find_program(PROTOC NAMES protoc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)

# ONNX_USE_PROTOBUF_SHARED_LIBS: find the library and check its file extension
find_library(PROTOBUF_LIBPATH NAMES protobuf PATHS "${CURRENT_INSTALLED_DIR}/bin" "${CURRENT_INSTALLED_DIR}/lib" REQUIRED)
get_filename_component(PROTOBUF_LIBNAME "${PROTOBUF_LIBPATH}" NAME)
if(PROTOBUF_LIBNAME MATCHES "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(USE_PROTOBUF_SHARED ON)
else()
    set(USE_PROTOBUF_SHARED OFF)
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPython_EXECUTABLE:FILEPATH=${PYTHON3}"
        "-DPython3_EXECUTABLE:FILEPATH=${PYTHON3}"
        "-DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}"
        -DONNX_ML=ON
        -DONNX_USE_PROTOBUF_SHARED_LIBS=${USE_PROTOBUF_SHARED}
        -DONNX_USE_LITE_PROTO=OFF
        -DONNX_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DONNX_BUILD_TESTS=OFF
        -DONNX_BUILD_CUSTOM_PROTOBUF=OFF
    MAYBE_UNUSED_VARIABLES
        ONNX_USE_MSVC_STATIC_RUNTIME
        Python_EXECUTABLE
        Python3_EXECUTABLE
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
