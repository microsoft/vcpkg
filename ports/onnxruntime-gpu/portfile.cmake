vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/onnxruntime/releases/download/v${VERSION}/onnxruntime-win-x64-gpu-${VERSION}.zip"
    FILENAME "onnxruntime-win-x64-gpu-${VERSION}.zip"
    SHA512 9576eafca59fc7f2af9f62d7ee8aa31208ef965d17f3ad71747d5a9a46cdffd6b3958dc945109d82937555df8bb35319ce92925e66ab707f1ca8e7564ecb3ced
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
    SHA512 3bf25e431d175c61953d28b1bf8f6871376684263992451a5b2a66e670768fc66e7027f141c6e3f4d1eddeebeda51f31ea0adf4749e50d99ee89d0a26bec77ce
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
