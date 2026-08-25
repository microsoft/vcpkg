vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openvinotoolkit/openvino
    REF "${VERSION}"
    SHA512 161ee93fb99df97ff7724411f4d697f90c70614840aee3eb40b865faad719f8e2e8892637b867fc3cd97c1de8ebadab84973c379c5a1927bed70ca2c74e6344c
    HEAD_REF master
    PATCHES
        msvc-debug-info-only-in-pdb.patch
        protobuf-6.patch
        levelzero-prepareheaders.patch
        android-ignore-onetbb-warning.patch
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
        REF v3.13
        SHA512 e2dc1a17252bff470c1dce2ef675d77308255ad3c9d40c3e77bcc3f560a2d1617f0878e5dec22a5012c31fb75809c0483a2cd8eefd5b9f2a2549a5afecf9135c
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
        REF f82d833de6f13fac4bb1926d521ca8fec4f4ae01
        SHA512 aea38db54ad75196d4475c8bcf9a7d781979d714f0eadf964337cff3f713a747e3a82f4c68c2597ecfd6ea882cf8a30e1a53f0425206e7c892b1e2e86a1e3201
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
            REF v53.1.0
            SHA512 6f49f1a66d8242d73d2f736668ea7156a2564d47b1eb8dc106095ec0f0b662873f65f8e3e47bdbfb769f273d9d7707d253ab3eba95b2830eb0ddbc80f657f718
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/ComputeLibrary")

        vcpkg_from_github(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            REPO ARM-software/kleidiai
            REF v1.26.0
            SHA512 bdb2fa30025d7cd885ab143df98f70c454e2ff7a5d94be6ac99cfa66dafa4a8dcd83f07652b285ef61ed8523bdb0d4c313b506cd1c71347d5400e935783fc459
        )
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_cpu/thirdparty/kleidiai")
    endif()
endif()

if(ENABLE_INTEL_GPU OR ENABLE_INTEL_NPU)
    list(APPEND FEATURE_OPTIONS "-DENABLE_SYSTEM_LEVEL_ZERO=ON")
endif()

if(ENABLE_INTEL_NPU)
    list(APPEND FEATURE_OPTIONS "-DENABLE_INTEL_NPU_INTERNAL=OFF")

    vcpkg_from_github(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        REPO intel/level-zero-npu-extensions
        REF f9ad3bf89c2418d714aef2e6b96a5aafb12a1971
        SHA512 ab450badbf3aa39ca9b753b0b3019c0d3fb6d267c4689cffca3c9a36163aaaebcba327f11991d5bc0798b6d5f530331e4456abdaec520e5ad486bfca9f6404ff
    )
    file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/plugins/intel_npu/thirdparty/level-zero-ext")

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_download_distfile(
            NPU_PLUGIN_COMPILER_ARCHIVE
            URLS "https://storage.openvinotoolkit.org/dependencies/thirdparty/windows/npu_compiler/npu_compiler_vcl_windows_2022-8_2_0-9802763.zip"
            FILENAME "npu_compiler_vcl_windows_2022-8_2_0-9802763.zip"
            SHA512 "5fbe44129b796b12c106a80a967fc9e50e561fcac1bd7b1a2f17cfd50462accfe82d3049f75512566c3d80963ee597e3003a1e0ce52ce7bb0280193ceed83fa3"
        )
        vcpkg_extract_archive(
            ARCHIVE ${NPU_PLUGIN_COMPILER_ARCHIVE}
            DESTINATION ${SOURCE_PATH}/npu_compiler
        )
        list(APPEND FEATURE_OPTIONS "-DNPU_PLUGIN_COMPILER_ROOT=${SOURCE_PATH}/npu_compiler")
    endif()
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

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS "-DENABLE_PDB_IN_RELEASE=ON")
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

if(ENABLE_INTEL_NPU AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB_RECURSE openvino_built_dlls "${CURRENT_PACKAGES_DIR}/*.dll")
    list(FILTER openvino_built_dlls EXCLUDE REGEX "/openvino_intel_npu_(compiler|compiler_loader|vm_runtime)\\.dll$")
    vcpkg_copy_pdbs(BUILD_PATHS ${openvino_built_dlls})

    foreach(config IN ITEMS "" "debug/")
        file(INSTALL
            "${SOURCE_PATH}/npu_compiler/pdb/openvino_intel_npu_compiler.pdb"
            "${SOURCE_PATH}/npu_compiler/pdb/openvino_intel_npu_compiler_loader.pdb"
            DESTINATION "${CURRENT_PACKAGES_DIR}/${config}bin"
        )
        file(INSTALL
            "${SOURCE_PATH}/npu_compiler/pdb/npu_interpreter_runtime.pdb"
            DESTINATION "${CURRENT_PACKAGES_DIR}/${config}bin"
            RENAME "openvino_intel_npu_vm_runtime.pdb"
        )
    endforeach()
else()
    vcpkg_copy_pdbs()
endif()

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
