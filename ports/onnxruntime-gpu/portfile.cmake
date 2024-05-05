vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/onnxruntime/releases/download/v${VERSION}/onnxruntime-win-x64-gpu-${VERSION}.zip"
    FILENAME "onnxruntime-win-x64-gpu-${VERSION}.zip"
    SHA512 7ab350a2ede0fc8c716cf083e16a9303acbcc855982e53900f8843773ec32fd20a7396f0bde82bb29f382012b1d05dea41708797f112d9096c8b5048fc5eb7d8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

# Download repo for experimental features
vcpkg_from_github(
    OUT_SOURCE_PATH REPO_PATH
    REPO microsoft/onnxruntime
    REF v${VERSION}
    SHA512 f2fec4ded88da6bf67ae7d0aa3082736cb3b8ba29e723b5a516d7632b68ce02aed461f24d3e82cbab20757729e0ab45d736bd986c9b7395f2879b16a091c12a1
)

file(COPY
        ${REPO_PATH}/include/onnxruntime/core/session/experimental_onnxruntime_cxx_api.h 
        ${REPO_PATH}/include/onnxruntime/core/session/experimental_onnxruntime_cxx_inline.h
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )

file(MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/include
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/lib
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )

file(COPY
        ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/include
        DESTINATION ${CURRENT_PACKAGES_DIR}
    )

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_cuda.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_cuda.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_cuda.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_cuda.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_shared.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_shared.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_tensorrt.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_tensorrt.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_shared.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_shared.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_tensorrt.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_tensorrt.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_shared.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_shared.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_tensorrt.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_tensorrt.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_cuda.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/lib/onnxruntime_providers_cuda.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
# # Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/onnxruntime-win-x64-gpu-${VERSION}/LICENSE")
