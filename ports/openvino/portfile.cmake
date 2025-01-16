vcpkg_download_distfile(PATCH_002_PROTOBUF # https://github.com/openvinotoolkit/openvino/pull/27510
    URLS https://github.com/openvinotoolkit/openvino/commit/103c3b72259648c990970afb8ce2bec489fcf583.patch?full_index=1
    SHA512 315eb2f651b55fc70a4d6faeb1ac1b5d90d53b9010fdc98f3417beb86854ed733eba105ea51de8795471c5e84340b96cf17d511ea3fe3447c5f961ded661a947
    FILENAME openvinotoolkit-openvino-103c3b72259648c990970afb8ce2bec489fcf583.patch
)

vcpkg_download_distfile(PATCH_003_CODE_SNIPPETS_TEMPALTE # https://github.com/openvinotoolkit/openvino/pull/28172
    URLS https://github.com/openvinotoolkit/openvino/commit/8d74cbb8e1af7c66ccee202fec5a18565e5b37b0.patch?full_index=1
    SHA512 24640b608c2eb78b948c257a8bc9bb0c2f05e4d6cb04c23cf7546a3191a73e163b4732590eb8e5b834765bb78472e1454785c20c74a4dcbaf40a34ff14fafc83
    FILENAME openvinotoolkit-openvino-8d74cbb8e1af7c66ccee202fec5a18565e5b37b0.patch
)

vcpkg_download_distfile(PATCH_004_ADD_CHRONO # https://github.com/openvinotoolkit/openvino/pull/28192
    URLS https://github.com/openvinotoolkit/openvino/commit/9d78056f243b1f8d5c0331420416c98a005e5945.patch?full_index=1
    SHA512 8b44e04ed88945174b17c6dada2ce3065340b6278a140717599ec0c33f548679424c5acd36b5edc10f2ed74c3288626c2b47a1af0ab530ed6a7ca868fe88ad4b
    FILENAME openvinotoolkit-openvino-9d78056f243b1f8d5c0331420416c98a005e5945.patch
)

vcpkg_download_distfile(PATCH_005_LEVEL_ZERO_FROM_SYSTEM # https://github.com/openvinotoolkit/openvino/pull/27633
    URLS https://github.com/openvinotoolkit/openvino/commit/5c2b9ac6b4daffc24762aea2f6dacdaa70d5ae8c.patch?full_index=1
    SHA512 85c2422ef78b853dd9937319cf16c915c3ce4a143f3a0628ffd4edf0ceac4c26d90e3ffd9d6c7f4f3f72fc631c4860fcfcbf96ce37134b31fc45ccae4f3df308
    FILENAME openvinotoolkit-openvino-5c2b9ac6b4daffc24762aea2f6dacdaa70d5ae8c.patch
)

vcpkg_download_distfile(PATCH_006_LEVEL_ZERO_AT_RUNTIME # https://github.com/openvinotoolkit/openvino/pull/27659
    URLS https://github.com/openvinotoolkit/openvino/commit/99d7cd4bc4492b81a99bc41e2d2469da1a929491.patch?full_index=1
    SHA512 091ad0328feb0ec9a59a9728ede444c408db9e7532b7a85b62b63f059fa766833b9c0b2d1c8e5972476652b24d62cf8bdb0313b197e2ea5e0b64c79a0a0da1b1
    FILENAME openvinotoolkit-openvino-99d7cd4bc4492b81a99bc41e2d2469da1a929491.patch
)

vcpkg_download_distfile(PATCH_007_OPENCL_V2024_10_24 # https://github.com/openvinotoolkit/openvino/pull/28275
    URLS https://github.com/openvinotoolkit/openvino/commit/120ad760494eeb513ea957bdbc655b6ad07bce42.patch?full_index=1
    SHA512 45a06bf54cef7d619b862f3219dd1225fb38bb653b2f09191d57e945a2df08621b15a27463429d5d72a18dfe05b113b94555cea0cabab0da36c9d89a2757196a
    FILENAME openvinotoolkit-openvino-120ad760494eeb513ea957bdbc655b6ad07bce42.patch
)

vcpkg_download_distfile(PATCH_008_FIX_LEVEL_ZERO_SYSTEM # https://github.com/openvinotoolkit/openvino/pull/28241
    URLS https://github.com/openvinotoolkit/openvino/commit/65f6ce8c5cd0ac5ae5f64fc1c533cc621475a105.patch?full_index=1
    SHA512 e756d181658dee933ffb727d004276a8fc37f9cfc473b25b0e0b5043234b1b2f021e1b26aa6513f7f40a9897d3c96b652aa7d81521205602f673d73a74cb5621
    FILENAME openvinotoolkit-openvino-65f6ce8c5cd0ac5ae5f64fc1c533cc621475a105.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF "${VERSION}"
    SHA512 b003647de3de49e605943488ca9b2e5196b20d95b3152f0c2331c283d4cb253d1bbbb9cde04fa82733d3871d7128c6db6210957660bd89f26462798f782eca47
    HEAD_REF master
    PATCHES
        # vcpkg specific patch, because OV creates a file in source tree, which is prohibited
        001-disable-tools.patch
        "${PATCH_002_PROTOBUF}"
        "${PATCH_003_CODE_SNIPPETS_TEMPALTE}"
        "${PATCH_004_ADD_CHRONO}"
        "${PATCH_005_LEVEL_ZERO_FROM_SYSTEM}"
        "${PATCH_006_LEVEL_ZERO_AT_RUNTIME}"
        "${PATCH_007_OPENCL_V2024_10_24}"
        "${PATCH_008_FIX_LEVEL_ZERO_SYSTEM}"
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
        REF 1722066ad4c0f15495f2d0fcbe9deb2bfd188c36
        SHA512 0b0461bf42d67f0fe7c6c61289a28e42915f7ac2ea5cc569957b8bb601962bec6135e84a2716911394952dffe2bb557c2d59d42c7f80a8db3c3937ecc6bd8ce8
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
        REF c60a9946aa2386890e5c9f5587974facb7624227
        SHA512 cc91f5b2ece1c3f14af308e3da436447d07964fa5ffa848c571fe67197a367673bf7bf9cd979fab0c9b216f92c611bd8df7018ec8e080f10759582629c10cb9d
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
