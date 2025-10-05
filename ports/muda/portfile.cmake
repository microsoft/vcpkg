vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "MuGdxy/muda"
    REF "${VERSION}"
    SHA512 c9b43735b6857497fa422cbf59bf31a6665479ec63a91079741f45685b18e982031d6544ae21caee4f8f294ccff326c3caafde6c315b7775b06d0f7e63761309
    HEAD_REF mini20
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        compute-graph   MUDA_WITH_COMPUTE_GRAPH
)

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
        "-DMUDA_BUILD_EXAMPLE=OFF"
        "-DMUDA_BUILD_TEST=OFF"
        "-DMUDA_WITH_CHECK=ON"
        "-DMUDA_WITH_NVTX3=OFF"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
