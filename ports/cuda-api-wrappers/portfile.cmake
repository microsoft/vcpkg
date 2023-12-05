vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalroz/cuda-api-wrappers
    REF "v${VERSION}"
    SHA512 4bc095513ed1a40f7239810abf7f6edcfde5471a89de8cf27a76038f6a54f6234542693bb606cc5e389403f3d12cb186b5a9cfb31c2bf3e437c112d215fb872d
    HEAD_REF master
)

# head only library
set(VCPKG_BUILD_TYPE release)

# cuda toolkit check
vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT)
message(STATUS "CUDA_TOOLKIT_ROOT ${CUDA_TOOLKIT_ROOT}")

# nvcc compiler path
set(CMAKE_CUDA_COMPILER "${CUDA_TOOLKIT_ROOT}/bin/nvcc${VCPKG_HOST_EXECUTABLE_SUFFIX}")

set(CUDA_ARCHITECTURES "native")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCAW_BUILD_EXAMPLES=OFF
        "-DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}"
        "-DCMAKE_CUDA_COMPILER=${CMAKE_CUDA_COMPILER}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
