if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/MNN
    REF 1.1.0
    SHA512 3e31eec9a876be571cb2d29e0a2bcdb8209a43a43a5eeae19b295fadfb1252dd5bd4ed5b7c584706171e1b531710248193bc04520a796963e2b21546acbedae0
    HEAD_REF master
    PATCHES
        use-package-and-install.patch
        fix-linux.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    test        MNN_BUILD_TEST
    test        MNN_BUILD_BENCHMARK
    cuda        MNN_CUDA
    vulkan      MNN_VULKAN
    opencl      MNN_OPENCL
    metal       MNN_METAL
    tools       MNN_BUILD_TOOLS
    tools       MNN_BUILD_QUANTOOLS
    tools       MNN_BUILD_TRAIN
    tools       MNN_EVALUATION
    tools       MNN_BUILD_CONVERTER
    gpu         MNN_GPU_TRACE
    system      MNN_USE_SYSTEM_LIB
)

# 'cuda' feature in Windows failes with Ninja because of parallel PDB access. Make it optional
set(NINJA_OPTION WINDOWS_USE_MSBUILD)
if(NOT "cuda" IN_LIST FEATURES)
    unset(NINJA_OPTION)
endif()

set(FLATC_EXEC "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers/flatc${VCPKG_HOST_EXECUTABLE_SUFFIX}")
if (NOT EXISTS "${FLATC_EXEC}")
    message(FATAL_ERROR "Expected ${FLATC_EXEC} to exist.")
endif()

# regenerate some code files by schemes and flatbuffers
vcpkg_execute_build_process(
    COMMAND "${FLATC_EXEC}" "-c" "-b" "--gen-object-api" "--reflect-names"
        "../default/BasicOptimizer.fbs"
        "../default/CaffeOp.fbs"
        "../default/GpuLibrary.fbs"
        "../default/MNN.fbs"
        "../default/Tensor.fbs"
        "../default/TensorflowOp.fbs"
        "../default/TFQuantizeOp.fbs"
        "../default/Type.fbs"
        "../default/UserDefine.fbs"
    WORKING_DIRECTORY "${SOURCE_PATH}/schema/current/"
    LOGNAME flatc-${TARGET_TRIPLET}
  )

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_RUNTIME_MT)
    list(APPEND PLATFORM_OPTIONS -DMNN_WIN_RUNTIME_MT=${USE_RUNTIME_MT})
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${NINJA_OPTION}
    OPTIONS
        ${FEATURE_OPTIONS} ${PLATFORM_OPTIONS}
        -DMNN_BUILD_SHARED_LIBS=${BUILD_SHARED}
        # 1.1.0.0-${commit}
        -DMNN_VERSION_MAJOR=1 -DMNN_VERSION_MINOR=1 -DMNN_VERSION_PATCH=0 -DMNN_VERSION_BUILD=0 -DMNN_VERSION_SUFFIX=-d6795ad
    OPTIONS_DEBUG
        -DMNN_DEBUG_MEMORY=ON -DMNN_DEBUG_TENSOR_SIZE=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_download_distfile(COPYRIGHT_PATH
    URLS "https://apache.org/licenses/LICENSE-2.0.txt"
    FILENAME 98f6b79b778f7b0a1541.txt
    SHA512 98f6b79b778f7b0a15415bd750c3a8a097d650511cb4ec8115188e115c47053fe700f578895c097051c9bc3dfb6197c2b13a15de203273e1a3218884f86e90e8
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${COPYRIGHT_PATH}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    if("metal" IN_LIST FEATURES)
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mnn.metallib"
                    "${CURRENT_PACKAGES_DIR}/share/${PORT}/mnn.metallib")
    endif()
else()
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if("test" IN_LIST FEATURES)
    # no install(TARGETS) for the following binaries. check the buildtrees...
    # vcpkg_copy_tools(
    #     TOOL_NAMES run_test.out benchmark.out benchmarkExprModels.out # test/
    #     AUTO_CLEAN
    # )
endif()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES MNNV2Basic.out mobilenetTest.out backendTest.out testModel.out testModelWithDescrisbe.out getPerformance.out checkInvalidValue.out timeProfile.out # tools/cpp
                   quantized.out # tools/quantization
                   classficationTopkEval.out # tools/evaluation
                   MNNDump2Json MNNConvert # tools/converter
                   transformer.out train.out dataTransformer.out runTrainDemo.out # tools/train
        AUTO_CLEAN
    )
    if(BUILD_SHARED)
        vcpkg_copy_tools(TOOL_NAMES TestConvertResult AUTO_CLEAN) # tools/converter
    endif()
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # remove the others. ex) mnn.metallib
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin
                        ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
