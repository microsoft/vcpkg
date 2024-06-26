vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF "${VERSION}"
    SHA512 0ddd66a331d7f7da873bf4a0517c65973c77c50c05252f9402aae5fa5dc394ce2631ba98cf084e5787110f5e669716e99224af7ddb477ae5990e77982b0f1b06
    PATCHES
        # vcpkg specific patch, because OV creates a file in source tree, which is prohibited
        001-disable-tools.patch
        # https://github.com/openvinotoolkit/openvino/pull/25069: disable apiValidator
        002-api-validator.patch
    HEAD_REF master)

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
    file(REMOVE_RECURSE ${SOURCE_PATH}/src/plugins/intel_gpu/thirdparty/rapidjson)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND ENABLE_INTEL_CPU)
        message(WARNING
            "OneDNN for GPU is not available for static build, which is required for dGPU. "
            "Please, consider using VCPKG_LIBRARY_LINKAGE=\"dynamic\" or disable CPU plugin, "
            "which uses another flavor of oneDNN.")
    else()
        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO oneapi-src/oneDNN
            REF 37f48519b87cf8b5e5ef2209340a1948c3e87d72
            SHA512 54801a402facf1b8d10d00594496430af94ce63152a026b449eae31aade6f040f788cd4d9b3f104b7dd6a2d8a689faf85cde2b8da9c150191792281d5cec7acc
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_gpu/thirdparty/onednn_gpu")
    endif()

    list(APPEND FEATURE_OPTIONS
        "-DENABLE_SYSTEM_OPENCL=ON"
        "-DPython3_EXECUTABLE=${PYTHON3}")
endif()

if(ENABLE_INTEL_CPU)
    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO openvinotoolkit/oneDNN
        REF 373e65b660c0ba274631cf30c422f10606de1618
        SHA512 eb876ef3c3a51d75565cdecde5872644f99c4b1420015ebe201dc91ead7c4501d8dcf8c1d61e78b277e30e114af13087d9ae6f8ae812d8a0debee597aca4232f
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

        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO ARM-software/ComputeLibrary
            REF v24.04
            SHA512 900f2e5bf399d298b9636f47a2f56131a2c8b9fe18a786c77b1f761a4f87283a891aec82328e6e6fc6fd62d36a84b7f397d66cd132a04c0d2605b7146a33026a
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/ComputeLibrary")
    endif()
endif()

if(ENABLE_INTEL_NPU)
    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO oneapi-src/level-zero
        REF 4ed13f327d3389285592edcf7598ec3cb2bc712e
        SHA512 1159b2dc59ffe201821aa6c4c65c1803f8be26654a5f7e09d4e2cea70afdaf6a49508acbc74279d2d5c8fc7b632ad29b70ea506c442cd599d7db47323de9e62d
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_npu/thirdparty/level-zero")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO intel/level-zero-npu-extensions
        REF d490a130fbb80e600b3aed3886c305abcb60d77c
        SHA512 a0ee41745bda5b4a4d602b70bc8aa6eb131510ba1dd80e5d0829e594f3be5e371770b114ac3c1ce9aebed9345470ec8a233de51feb9f780a5d661577c2ee8c2d
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_npu/thirdparty/level-zero-ext")
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

if(CMAKE_HOST_WIN32)
    list(APPEND FEATURE_OPTIONS "-DENABLE_API_VALIDATOR=OFF")
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
        "-DENABLE_PYTHON=OFF"
        "-DCPACK_GENERATOR=VCPKG"
        "-DENABLE_JS=OFF"
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
