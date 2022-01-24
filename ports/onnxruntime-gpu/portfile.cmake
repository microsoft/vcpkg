vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VERSION 1.5.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/onnxruntime/releases/download/v1.5.1/onnxruntime-win-x64-gpu-1.5.1.zip"
    FILENAME "onnxruntime-win-x64-gpu-1.5.1.zip"
    SHA512 893dbed1196b5c9730744dc5566cd3ad8ec677cbea04dd0572efc9a8b3563d3f1cbf40d0dea3d624d9451dc33272c0ae44d53d6deee6f249fa2520e60718ee52
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    REF ${VERSION}
)

file(MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/include
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/lib
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )

file(COPY
        ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.5.1/include
        DESTINATION ${CURRENT_PACKAGES_DIR}
    )

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.5.1/lib/onnxruntime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.5.1/lib/onnxruntime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.5.1/lib/onnxruntime.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.5.1/lib/onnxruntime.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.5.1/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
