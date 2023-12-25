vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF "${VERSION}"
    SHA512 d44aa06763b18fabb6e9fb52834cbe9b6c91384541177093741519c7cf6f209720cb9aabf0b4a2b2b32625399ca2076d7b1a3430ea00dadeda86255fb8baf720
    PATCHES
        # vcpkg specific patch, because OV creates a file in source tree, which is prohibited
        001-disable-tools.patch
        # https://github.com/openvinotoolkit/openvino/pull/19628
        002-git-version.patch
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
            PATCHES 006-onednn-gpu-build.patch
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
        REF 2ead5d4fe5993a797d9a7a4b8b5557b96f6ec90e
        SHA512 e254f331275e174e7f191f99bf2abcea73aa5954efd0984e1a8418ffa73d2de1ad148e77314b4be04f36ac293202e01835be0ac6e65a6af1391258987aaa8dc4
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/onednn")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO openvinotoolkit/mlas
        REF f6425b1394334822390fcd9da12788c9cd0d11da
        SHA512 3b7fc28ad80a85a459f3370ba84acf79355c3d14be68df57c436e8e0f7b8a3e37ef192fc9b0db2f751dac458f3ef2e9ccb8dbe08e2d31c4636ea30eb970628fe
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
