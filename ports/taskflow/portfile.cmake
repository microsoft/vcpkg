# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF "v${VERSION}"
    SHA512 9609c2d0851dc306d93d6b08e3330413ebc8f6eda4af57b0204446ab4c86fca886c7f9349e8ec92767c11b90b7a64dd52c56e6b34a89eca5ba37235b38665f8e
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
