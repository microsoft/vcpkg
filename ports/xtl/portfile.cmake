# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xtl
    REF 0.5.2
    SHA512 31a5f99ba77b8a2c01ee048057b62ea29665228969bab2866c35f72181c8a9fc3720dbdf94c8630303d627acaec6a296d8b494b0df66e161d248b370e5c2512e
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
