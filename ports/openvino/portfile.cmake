vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF "${VERSION}"
    SHA512 29ee621c1428808607ce499e527b5943b8a2172769cb7315ef25253db818f54f2da4bbf5539198c012e25e78c8c830205b46f6e6a83032e732e82a7d00d46312
    PATCHES
        # vcpkg specific patch, because OV creates a file in source tree, which is prohibited
        001-disable-tools.patch
        # from https://github.com/openvinotoolkit/openvino/pull/18359
        003-fix-find-onnx.patch
        # from https://github.com/openvinotoolkit/openvino/pull/19629
        004-compilation-with-cpp17.patch
        # from https://github.com/openvinotoolkit/openvino/pull/19599
        005-tflite-search.patch
        # # from https://github.com/openvinotoolkit/openvino/pull/19946
        007-macos-14.patch
        # from https://github.com/openvinotoolkit/openvino/pull/19758
        # and https://github.com/openvinotoolkit/openvino/pull/20612
        008-dynamic-protubuf.patch
        # from https://github.com/openvinotoolkit/openvino/pull/20588
        # and https://github.com/openvinotoolkit/openvino/pull/20636
        009-tensorflow-proto-odr.patch
    HEAD_REF master)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpu             ENABLE_INTEL_CPU
        gpu             ENABLE_INTEL_GPU
        auto            ENABLE_AUTO
        hetero          ENABLE_HETERO
        auto-batch      ENABLE_AUTO_BATCH
        ir              ENABLE_OV_IR_FRONTEND
        onnx            ENABLE_OV_ONNX_FRONTEND
        paddle          ENABLE_OV_PADDLE_FRONTEND
        pytorch         ENABLE_OV_PYTORCH_FRONTEND
        tensorflow      ENABLE_OV_TF_FRONTEND
        tensorflow-lite ENABLE_OV_TF_LITE_FRONTEND
)

if(ENABLE_INTEL_GPU)
    # python is required for conversion of OpenCL source files into .cpp.
    vcpkg_find_acquire_program(PYTHON3)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        message(WARNING
            "OneDNN for GPU is not available for static build, which is required for dGPU."
            "Please, consider using VCPKG_LIBRARY_LINKAGE=\"dynamic\".")
        list(APPEND FEATURE_OPTIONS "-DENABLE_ONEDNN_FOR_GPU=OFF")
    else()
        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO oneapi-src/oneDNN
            REF ec0b2ee85fc2a2dbdeec10035c5ef5813d8fb5ea
            SHA512 abc09c9ab190cc043ba675fdcaf2da0069eacce14aad6e788a9957d8b6704cfcefe5a707e78d544d25acac35bc83217660ee64528150311f577d2ccbdd165de1
            PATCHES 006-onednn-gpu-build.patch
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_gpu/thirdparty/onednn_gpu")
    endif()

    list(APPEND FEATURE_OPTIONS
        "-DENABLE_SYSTEM_OPENCL=ON"
        "-DPYTHON_EXECUTABLE=${PYTHON3}")
endif()

if(ENABLE_INTEL_CPU)
    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO openvinotoolkit/oneDNN
        REF a1aa20ca8f19465dc2fd18389953ed83798b2fd3
        SHA512 0ff5b235a6f349ad94f52a3b8282f5c825eac7275ad784986d7f533863ace7a4ed71094b9f5cac85d473d2678e197727c1cb33dee5cf75cd793ded7be58f946e
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/onednn")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO openvinotoolkit/mlas
        REF c7c8a631315000f17c650af34431009d2f22129c
        SHA512 4146598ce6b30a3eaea544d6703b949061118398e67b773aa11a3c0f3e8fbcc446d09ea893b9879f8869e977162bcada0d4895cb225cf2e2469fb71cd5942e53
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/mlas")

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        # scons (python tool) is required for ARM Compute Library building
        vcpkg_find_acquire_program(PYTHON3)

        x_vcpkg_get_python_packages(
            PYTHON_VERSION 3
            PYTHON_EXECUTABLE ${PYTHON3}
            PACKAGES scons
            OUT_PYTHON_VAR OV_PYTHON_WITH_SCONS
        )

        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO ARM-software/ComputeLibrary
            REF v23.02.1
            SHA512 ee9439e0804bacd365f079cedc548ffe2c12b0d4a86780e0783186884eb5a6d7aa7ceac11c504e242bedc55c3d026b826c90adaafbdbd3e5cfa2562a1c4ee04d
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/ComputeLibrary")
    endif()
endif()

if(ENABLE_OV_TF_FRONTEND OR ENABLE_OV_ONNX_FRONTEND OR ENABLE_OV_PADDLE_FRONTEND)
    list(APPEND FEATURE_OPTIONS "-DENABLE_SYSTEM_PROTOBUF=ON")
endif()

if(ENABLE_OV_TF_FRONTEND)
    list(APPEND FEATURE_OPTIONS "-DENABLE_SYSTEM_SNAPPY=ON")
endif()

if(ENABLE_OV_TF_LITE_FRONTEND)
    list(APPEND FEATURE_OPTIONS "-DENABLE_SYSTEM_FLATBUFFERS=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DENABLE_SYSTEM_TBB=ON"
        "-DENABLE_SYSTEM_PUGIXML=ON"
        "-DENABLE_TBBBIND_2_5=OFF"
        "-DENABLE_CLANG_FORMAT=OFF"
        "-DENABLE_NCC_STYLE=OFF"
        "-DENABLE_CPPLINT=OFF"
        "-DENABLE_SAMPLES=OFF"
        "-DENABLE_TEMPLATE=OFF"
        "-DENABLE_INTEL_GNA=OFF"
        "-DENABLE_PYTHON=OFF"
        "-DENABLE_GAPI_PREPROCESSING=OFF"
        "-DCPACK_GENERATOR=VCPKG"
        "-DCMAKE_DISABLE_FIND_PACKAGE_pybind11=ON"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/licensing/third-party-programs.txt"
        "${SOURCE_PATH}/licensing/onednn_third-party-programs.txt"
        "${SOURCE_PATH}/licensing/runtime-third-party-programs.txt"
    COMMENT
        "OpenVINO License")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
