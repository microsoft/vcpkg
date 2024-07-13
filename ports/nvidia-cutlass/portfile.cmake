vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cutlass
    REF "v${VERSION}"
    SHA512 989b62323f81708fd41a16aab10b7fc179dc9a66704446ab5d8f97160d9acf2958646dac58ac3aa2b04fff294a5c126192d2e88a7bea9f902130c8c051dc196f
    HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_PATH "${PYTHON3}" PATH)
vcpkg_add_to_path(PREPEND "${PYTHON_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCUTLASS_REVISION:STRING=v${VERSION}"
        -DCUTLASS_ENABLE_HEADERS_ONLY=ON
        -DCUTLASS_ENABLE_PERFORMANCE=OFF
        -DCUTLASS_ENABLE_CUBLAS=ON
        -DCUTLASS_ENABLE_CUDNN=ON
        -DCUTLASS_ENABLE_PROFILER=OFF
        "-DPython3_EXECUTABLE:FILEPATH=${PYTHON3}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/NvidiaCutlass" PACKAGE_NAME "NvidiaCutlass")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/test"
    "${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
