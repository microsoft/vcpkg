vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ilya-lavrenov/openvino
    REF e059a311302c43f74868d7a221a505b97c49e62d
    SHA512 cbc2d7783c0a0d3dcab3ea997daa9c183ae85b5ec121d1613b1dad627f2089acf6206aba4706519d4b3309a33675a2bd54a8765f614ccea160a872672fdafa09
    PATCHES
        001-disable-tools.patch
        002-cpu-plugin-x86.patch
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

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND ENABLE_INTEL_CPU)
        message(WARNING
            "OneDNN for GPU is not available for static build, which is required for dGPU."
            "Please, consider using VCPKG_LIBRARY_LINKAGE=\"dynamic\" or disable CPU plugin,"
            "which uses another flavor of oneDNN.")
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
        REF 31c8555b923e16b4ddfdcd1d1f126c115b5e0da7
        SHA512 77a9e5a84ff62ae8014b8b5c48d05ee004ee26320bc8aa9bafc8323c55d609119b0553385defb842e0394ec07ec34d48b4df322ad6d10990d907618ef27a326c
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
