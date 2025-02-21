vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/llama.cpp
    REF b${VERSION}
    SHA512 e093f4c7d4b2de425932bb4960683527a8a3bba242132c2f5e5bfed8480f0e336a06f97baf2d20ee591c6deee7535e159d40884a5e3f7caf0ae0967b8a046850
    HEAD_REF master
    PATCHES
        0001-external-ggml.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ggml")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DGGML_CCACHE=OFF
      -DLLAMA_BUILD_TESTS=OFF
      -DLLAMA_ALL_WARNINGS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME llama CONFIG_PATH "lib/cmake/llama")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

set(TOOLS_LIST llama-batched-bench llama-batched llama-embedding llama-eval-callback llama-gguf-hash llama-gguf-split llama-gguf llama-gritlm llama-imatrix llama-infill llama-bench llama-lookahead llama-lookup llama-lookup-create llama-lookup-merge llama-lookup-stats llama-cli llama-parallel llama-passkey llama-perplexity llama-quantize llama-retrieval llama-server llama-save-load-state llama-run llama-simple llama-simple-chat llama-speculative llama-speculative-simple llama-tokenize llama-tts llama-gen-docs llama-convert-llama2c-to-ggml llama-cvector-generator llama-export-lora llama-llava-cli llama-minicpmv-cli llama-qwen2vl-cli llama-llava-clip-quantize-cli)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND ${TOOLS_LIST} llama-gbnf-validator)
    list(APPEND ${TOOLS_LIST} llama-quantize-stats)
endif()
vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES ${TOOLS_LIST})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if (VCPKG_LIBRARY_LINKAGE MATCHES "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
