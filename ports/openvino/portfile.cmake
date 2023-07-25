vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF 50c85f01ab44b2470f08b0f8824cced109628fc6
    SHA512 1673cdab4f0d73ba5e3d0ac1e8a7b136d25df59704575a468016650c3c6c0dcba0bdc0a2306f61a14d49792651b21e9233d166610e0b463624b309758f1b1c04
    PATCHES
        001-disable-tools.patch
        002-typo-in-default-option-value.patch
    HEAD_REF master)

function(ov_checkout_in_path PATH REPO REF SHA512)
    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO ${REPO}
        REF ${REF}
        SHA512 ${SHA512}
    )

    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/${PATH}")
endfunction()

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
        ov_checkout_in_path(
            src/plugins/intel_gpu/thirdparty/onednn_gpu
            oneapi-src/oneDNN
            f27dedbfc093f51032a4580198bb80579440dc15
            882eb42e31490df1b35b5e55bef1be8452b710b7a16f5ad648961510abd288e16dbd783e0163aab9dd161fd3a9bd836b0f4afc82b14043d80d1dad9c3400af1b
        )
    endif()

    list(APPEND FEATURE_OPTIONS
        "-DENABLE_SYSTEM_OPENCL=ON"
        "-DPYTHON_EXECUTABLE=${PYTHON3}")
endif()

if(ENABLE_INTEL_CPU)
    ov_checkout_in_path(
        src/plugins/intel_cpu/thirdparty/onednn
        openvinotoolkit/oneDNN
        48bf41e04ba8cdccb1e7ad166fecfb329f5f84a1
        8a5ef1ce07545bc28328d1cfd49a8ee8f2ff13c2e393623cb842982b83963881f3d096230805d2a187100c68a2ca30c99add5a975f3f623d9f4a51517c2d585f
    )

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        # scons (python tool) is required for ARM Compute Library building
        vcpkg_find_acquire_program(PYTHON3)

        x_vcpkg_get_python_packages(
            PYTHON_VERSION 3
            PYTHON_EXECUTABLE ${PYTHON3}
            PACKAGES scons
            OUT_PYTHON_VAR OV_PYTHON_WITH_SCONS
        )

        ov_checkout_in_path(
            src/plugins/intel_cpu/thirdparty/ComputeLibrary
            ARM-software/ComputeLibrary
            v23.02.1
            ee9439e0804bacd365f079cedc548ffe2c12b0d4a86780e0783186884eb5a6d7aa7ceac11c504e242bedc55c3d026b826c90adaafbdbd3e5cfa2562a1c4ee04d
        )
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
        "-DENABLE_COMPILE_TOOL=OFF"
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
        "${SOURCE_PATH}/licensing/tbb_third-party-programs.txt"
        "${SOURCE_PATH}/licensing/onednn_third-party-programs.txt"
        "${SOURCE_PATH}/licensing/runtime-third-party-programs.txt"
    COMMENT
        "OpenVINO License")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
