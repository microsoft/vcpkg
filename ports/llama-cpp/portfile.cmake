vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/llama.cpp
    REF v${VERSION}
    SHA512 b82f755c40897d273ec3784f4f22b02f6a5f5f7b3c2a4240495d13a4617575c9aa69597de6a4f0b9a6568f51cc976e0b72ac847d83c2f953ed7fa52365e71d9a
    HEAD_REF master
    PATCHES
        cmake-config.diff
        pkgconfig.diff
        unvendor.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/ggml/include" "${SOURCE_PATH}/ggml/src")
file(REMOVE_RECURSE
    "${SOURCE_PATH}/vendor/cpp-httplib"
    "${SOURCE_PATH}/vendor/miniaudio"
    "${SOURCE_PATH}/vendor/nlohmann"
    "${SOURCE_PATH}/vendor/stb")

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        server      LLAMA_BUILD_SERVER
        tools       LLAMA_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DGGML_CCACHE=OFF
        -DLLAMA_BUILD_IS_DEV=OFF
        -DLLAMA_BUILD_APP=OFF
        -DLLAMA_BUILD_UI=OFF
        -DLLAMA_USE_PREBUILT_UI=OFF
        -DLLAMA_ALL_WARNINGS=OFF
        -DLLAMA_BUILD_TESTS=OFF
        -DLLAMA_BUILD_EXAMPLES=OFF
        -DLLAMA_USE_SYSTEM_GGML=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Git=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/llama")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/gguf-py/gguf" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/gguf-py")
file(INSTALL "${SOURCE_PATH}/conversion" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/convert_hf_to_gguf.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}" RENAME convert-hf-to-gguf.py)

if("tools" IN_LIST FEATURES)
    set(tool_names
        llama-batched-bench
        llama-bench
        llama-completion
        llama-fit-params
        llama-gguf-split
        llama-imatrix
        llama-mtmd-cli
        llama-perplexity
        llama-quantize
        llama-results
        llama-tokenize
        llama-tts
    )
    # These tools require the CPU backend, which ggml disables for MSVC arm64.
    if(NOT (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
        list(APPEND tool_names llama-cvector-generator llama-export-lora)
    endif()
    if("server" IN_LIST FEATURES)
        list(APPEND tool_names llama-cli llama-server)
    endif()
    vcpkg_copy_tools(
        TOOL_NAMES ${tool_names}
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_clean_executables_in_bin(FILE_NAMES none)

set(gguf-py-license "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gguf-py LICENSE")
file(COPY_FILE "${SOURCE_PATH}/gguf-py/LICENSE" "${gguf-py-license}")
set(copyright_files
    "${SOURCE_PATH}/LICENSE"
    "${gguf-py-license}"
    "${SOURCE_PATH}/vendor/sheredom/subprocess.h"
)
if("tools" IN_LIST FEATURES)
    list(APPEND copyright_files
        "${SOURCE_PATH}/vendor/hash/xxhash/LICENSE"
        "${SOURCE_PATH}/vendor/hash/sha1/sha1.h"
        "${SOURCE_PATH}/vendor/hash/sha256/sha256.h"
        "${SOURCE_PATH}/vendor/hash/rotate-bits/LICENSE.md"
    )
endif()
vcpkg_install_copyright(FILE_LIST ${copyright_files})
