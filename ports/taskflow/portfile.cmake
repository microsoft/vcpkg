# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF v3.4.0
    SHA512 e0e3589feec65677c4de6583a70c14f90826f2177636010955c597a3232f7842431c697eae711318f4a64fae52ac3e33e2d0739ef36bb7c57698110b6fa4740d
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
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
