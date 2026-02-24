vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF "${VERSION}"
    SHA512 77259f2211aa27c70c4930795ab6a7f7a0eade6fa8cda9b38caafdb3fa8081dba7c6bb5c2fa75adbdb224e4d84c80c48f19eef463500cd58316aa55183e6d660
    HEAD_REF master
    PATCHES
        windows_fix_giant_libs.patch
        onednn_gpu_includes.patch
        protobuf-6.patch
        npu_deps.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpu             ENABLE_INTEL_CPU
        gpu             ENABLE_INTEL_GPU
        npu             ENABLE_INTEL_NPU
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

    # remove 'rapidjson' directory and use vcpkg's one to comply with ODR
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/plugins/intel_gpu/thirdparty/rapidjson")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO oneapi-src/oneDNN
        REF v3.11
        SHA512 de60ecd881b97e9942441e0eb5c53e2caa2a0a1a1c78ab9211ab103244b66b62c0f3dfa5b322bb2c39dfe13f85a9aebf82b899dde1ccdc01ba8ff9deed832787
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_gpu/thirdparty/onednn_gpu")

    list(APPEND FEATURE_OPTIONS
        "-DENABLE_SYSTEM_OPENCL=ON"
        "-DPython3_EXECUTABLE=${PYTHON3}")
endif()

if(ENABLE_INTEL_CPU)
    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO openvinotoolkit/oneDNN
        REF c6b79c1207bd5f20b9395536dab1d71a47cfcb1d
        SHA512 2ed3444c60771229f051688964ee51b7cd229f75dfdbc6e59390d64223bb5d98074dd30cd4cd2458725bfba147bdf985bcc1d7ba8291f097ff4f291859b35ce3
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/onednn")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO openvinotoolkit/mlas
        REF d1bc25ec4660cddd87804fcf03b2411b5dfb2e94
        SHA512 8d6dd319924135b7b22940d623305bf200b812ae64cde79000709de4fad429fbd43794301ef16e6f10ed7132777b7a73e9f30ecae7c030aea80d57d7c0ce4500
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

        list(APPEND FEATURE_OPTIONS "-DPython3_EXECUTABLE=${OV_PYTHON_WITH_SCONS}")

        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO ARM-software/ComputeLibrary
            REF v52.6.0
            SHA512 b7f0c5b33466a064e87fbc549fbb78f49c03ef10d50d5e84a9e8dca66094e469cff5d6c5ec01e26873e957e74e8b8a8472c369ab8aeea74c7c36ad0dfe1ad152
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/ComputeLibrary")

        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO ARM-software/kleidiai
            REF v1.19.0
            SHA512 46de1f0cdd04ce1e8de5d1bdb2499d07eb377e616eb3a8596fbcd296b7887e413be5470f383b5790cef73dc370bead3db36ef2ed116513b95924ae71d87ef123
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/kleidiai")
    endif()
endif()

if(ENABLE_INTEL_NPU)
    list(APPEND FEATURE_OPTIONS
        "-DENABLE_INTEL_NPU_INTERNAL=OFF"
        "-DENABLE_SYSTEM_LEVEL_ZERO=ON")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO intel/level-zero-npu-extensions
        REF 8404c63a88d182726038d2b07c219731dada9c21
        SHA512 701c3dbb3fc016a5b2fd70b68375a8191013299b8824bdd2a2830efd69cadc3d4b104b6479c37a46164d1a1a9781e8cc50eebb96c0ada64743e5e2b9456bb1af
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_npu/thirdparty/level-zero-ext")
endif()

if(ENABLE_OV_TF_FRONTEND OR ENABLE_OV_ONNX_FRONTEND OR ENABLE_OV_PADDLE_FRONTEND)
    list(APPEND FEATURE_OPTIONS "-DENABLE_SYSTEM_PROTOBUF=ON")
endif()

if(ENABLE_OV_TF_FRONTEND)
    list(APPEND FEATURE_OPTIONS "-DENABLE_SYSTEM_SNAPPY=ON")
endif()

if(ENABLE_OV_TF_LITE_FRONTEND OR ENABLE_INTEL_NPU)
    list(APPEND FEATURE_OPTIONS "-DENABLE_SYSTEM_FLATBUFFERS=ON")
endif()

if(CMAKE_HOST_WIN32)
    list(APPEND FEATURE_OPTIONS "-DENABLE_API_VALIDATOR=OFF")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_DISABLE_FIND_PACKAGE_OpenCV=ON"
        "-DCPACK_GENERATOR=VCPKG"
        "-DENABLE_CLANG_FORMAT=OFF"
        "-DENABLE_JS=OFF"
        "-DENABLE_NCC_STYLE=OFF"
        "-DENABLE_PYTHON=OFF"
        "-DENABLE_SAMPLES=OFF"
        "-DENABLE_SYSTEM_PUGIXML=ON"
        "-DENABLE_SYSTEM_TBB=ON"
        "-DENABLE_TBBBIND_2_5=OFF"
        "-DENABLE_TEMPLATE=OFF"
        "-DENABLE_PROFILING_ITT=OFF"
        "-DENABLE_OV_JAX_FRONTEND=OFF"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
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
