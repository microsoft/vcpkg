# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF "v${VERSION}"
    SHA512 2faecc9eaf9e7f24253a5aedbb4ef6164ba8b5181b7f2c65d8646c21300f28278d7817e928eeab7e85ec2b9644508a8665bab1a7482ec85a7f6de18cecb32d6f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTF_BUILD_BENCHMARKS=OFF
        -DTF_BUILD_CUDA=OFF
        -DTF_BUILD_TESTS=OFF
        -DTF_BUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_CUDA_COMPILER=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Taskflow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
