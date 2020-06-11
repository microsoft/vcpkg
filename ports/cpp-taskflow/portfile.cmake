# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF v2.2.0
    SHA512 1aa4e9d7324f56eb33cd4986d721035f0abf12e022da956bafc0b16cf6cb82d152334ae58edc4581ab2f6d44989ca21cdd590ad560d6f1a4f905710fe08d0091
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTF_BUILD_EXAMPLES=OFF
        -DTF_BUILD_TESTS=OFF
        -DTF_BUILD_BENCHMARKS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)