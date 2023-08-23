vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/onnxruntime/releases/download/v${VERSION}/onnxruntime-win-x64-gpu-${VERSION}.zip"
    FILENAME "onnxruntime-win-x64-gpu-${VERSION}.zip"
    SHA512 f927302daa7b778eaf15693e446303060c0a38dfd18b8026c28ac65f545dd463ee7cd3f0aa6bfe59301c5c85ccf4512584ed968ac42ce8d78c12a79d8af2de1e
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
    SHA512 d8f7ea161e850a738b9a22187662218871f88ad711282c58631196a74f4a4567184047bab0001b973f841a3b63c7dc7e350f92306cc5fa9a7adc4db2ce09766f
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
