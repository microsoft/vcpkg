vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ilya-lavrenov/openvino
    REF 6117fc90c2fe65f51efd81fd9f202be9f06f5fd3
    SHA512 c703c69f20b0e5f169841de41ece5cd7cd2fac444e604f53dda4e7e347b2bfe608703f2773f778b367d5b7c0189756c4e5d717b7750db9b09489f2d8e3d6397f
    PATCHES
        001-disable-tools.patch
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

    # remove 'rapidjson' directory and use vcpkg's one to comply with ODR
    file(REMOVE_RECURSE ${SOURCE_PATH}/src/plugins/intel_gpu/thirdparty/rapidjson)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND ENABLE_INTEL_CPU)
        message(WARNING
            "OneDNN for GPU is not available for static build, which is required for dGPU."
            "Please, consider using VCPKG_LIBRARY_LINKAGE=\"dynamic\" or disable CPU plugin,"
            "which uses another flavor of oneDNN.")
    else()
        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO oneapi-src/oneDNN
            REF 284ad4574939fa784e4ddaa1f4aa577b8eb7a017
            SHA512 b8b003659b5972ce7a4d5cfd6bcac9377d06055fa67bd2830af0780b2272d2faed3d1d58fb1cbd5aa8bee68c9d6005ac5ae63381b5f80c3ac86442f88cce73a3
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
        REF 36c2060a0dc85b4def72ea30823936c2ef861b82
        SHA512 2a3b0bdb05b5d86ac2b69513d67a8ff317b1b8972de798cf95deeb2bb47a5935425c5ee7772cea5bc4b5ebd0ba8acf1180a28fa5db77bd2f01580fa0a6ae6cc1
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
            REF v23.08
            SHA512 8379fdf804732ef4e69a3e91807810d413f35855d035cfde9d81059679f62cd625c0347f07dc1f76468dc82c06217a5ae8df25b4581a29558ac32b2a4f7d8af4
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
