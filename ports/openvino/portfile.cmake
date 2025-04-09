vcpkg_download_distfile(PATCH_001_FIX_BUILD_WITH_ONEDNN_FROM_VCPKG # https://github.com/openvinotoolkit/openvino/pull/28816
    URLS https://github.com/openvinotoolkit/openvino/commit/d51bcdb17ca9f010e761c1e55198743242c4e186.patch?full_index=1
    SHA512 67c03d2e13ebeaa275dbe856a833032d478d125f5e6d19c3475f064bddf74225490960fabf159935a045bceb4f449983badd9e6fb0fc2b96f9faebea20d2f81f
    FILENAME openvinotoolkit-openvino-d51bcdb17ca9f010e761c1e55198743242c4e186.patch
)

vcpkg_download_distfile(PATCH_002_FIX_BUILD_WITH_ONEDNN_FROM_VCPKG_PART_2 # https://github.com/openvinotoolkit/openvino/pull/28899
    URLS https://github.com/openvinotoolkit/openvino/commit/66a612c7ba0077b72f7f035e90e0d1471add34ff.patch?full_index=1
    SHA512 ae1e946438b86d6d6372ee034c7e468be9d64bd2b04a9d6f1c4946349cf7b60594e0e2caa2e1ca40e5d13bd9f13f12a27fb0bb02fd3b11e1715708f32680aac3
    FILENAME openvinotoolkit-openvino-66a612c7ba0077b72f7f035e90e0d1471add34ff.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF "${VERSION}"
    SHA512 a40636fbed5b306dc6eb26311ccd6298763a2ede28d8ccce75e6d99f13747d42d1bd9fede8fa225e23fd70f81fbb522ab5076edc08898ca33fc9ffa69b7c2e1a
    HEAD_REF master
    PATCHES
        "${PATCH_001_FIX_BUILD_WITH_ONEDNN_FROM_VCPKG}"
        "${PATCH_002_FIX_BUILD_WITH_ONEDNN_FROM_VCPKG_PART_2}"
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
        REF 706a3ce3b391cf1d8a904a8efa981c70078719eb
        SHA512 aebb705f9c785f5522f204a7cece95616c801d73e50b07ad5f5a53eec006a3259e92de59f81fbda9cd1b784916010cba738af76bd129dbca52ce5cf17d6b6594
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
        REF 1789b1e0ae441de15d793123003a900a35d1dc71
        SHA512 32ef59542d8e2286b9b201dc94254f4b3b0c561446f05720e9ce7ce14a08fc40b331d765764d85f953cc3ca774b3e1c4f9a75b505aea285c3e18cae1a3c117cc
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
            REF v24.09
            SHA512 c755da7d576b9bc1f33c9505efe4ce9e50cb927978f929d61f31b213904dca45ddb78b7c0cf9b215e37d2028e0404f4e3435678c120bba16263b55fd701eb4f1
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/ComputeLibrary")
    endif()
endif()

if(ENABLE_INTEL_NPU)
    list(APPEND FEATURE_OPTIONS
        "-DENABLE_INTEL_NPU_INTERNAL=OFF"
        "-DENABLE_SYSTEM_LEVEL_ZERO=ON")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO intel/level-zero-npu-extensions
        REF 110f48ee8eda22d8b40daeeecdbbed0fc3b08f8b
        SHA512 aaaeecad6c00489b652cd94d63ed0c1e59eb0eaed8b463198b40f1af3944004b072808ccc3074b71d825e9f0f37bf76fedf296961bb18959ef66a699b71fec41
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

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_DISABLE_FIND_PACKAGE_OpenCV=ON"
        "-DCPACK_GENERATOR=VCPKG"
        "-DENABLE_CLANG_FORMAT=OFF"
        "-DENABLE_CPPLINT=OFF"
        "-DENABLE_JS=OFF"
        "-DENABLE_NCC_STYLE=OFF"
        "-DENABLE_PYTHON=OFF"
        "-DENABLE_SAMPLES=OFF"
        "-DENABLE_SYSTEM_PUGIXML=ON"
        "-DENABLE_SYSTEM_TBB=ON"
        "-DENABLE_TBBBIND_2_5=OFF"
        "-DENABLE_TEMPLATE=OFF"
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
