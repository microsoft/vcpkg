include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueBrain/HighFive
    REF v1.5
    SHA512 4133ec2768f54cb3e56c32f3193d6c61ea96013dc73901c39d31ecaf10b04ea2861b0f6f5c9795985050ef72a75e2d360a4b906c9cdeb8ee49309961e15d39bf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DHIGHFIVE_UNIT_TESTS=OFF
        -DHIGHFIVE_EXAMPLES=OFF
        -DUSE_BOOST=OFF
        -DHIGH_FIVE_DOCUMENTATION=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/HighFive/CMake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/highfive RENAME copyright)
