# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF "v${VERSION}"
    SHA512 ca56f07db18767483ef6c2371a0dd9675e4f848cce891fe0ade85ec38609c08ddac2152a227a511c65901ade27439a988cdf70ad6841489f2bdbf712cde97f44
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTF_BUILD_BENCHMARKS=OFF
        -DTF_BUILD_CUDA=OFF
        -DTF_BUILD_TESTS=OFF
        -DTF_BUILD_EXAMPLES=OFF
        -DCMAKE_CUDA_COMPILER=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Taskflow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
