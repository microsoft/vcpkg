# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xtl
    REF 0.5.3
    SHA512 340e10a113d88be81833e8c123835de0fd30bc9b80387cd260edbff5e54ff2d78a72f77ec8803e3031f54f32c7f189a7afc9e0c1b7446fc6340a4482f308ccbf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDOWNLOAD_GTEST=OFF
        -DTF_BUILD_EXAMPLES=OFF
        -DTF_BUILD_TESTS=OFF
        -DTF_BUILD_BENCHMARKS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
