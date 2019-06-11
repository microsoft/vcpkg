include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yaml/libyaml
    REF 0.2.2
    SHA512 455494591014a97c4371a1f372ad09f0d6e487e4f1d3419c98e9cd2f16d43a0cf9a0787d7250bebee8b8d400df4626f5acd81e90139e54fa574a66ec84964c06
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/config.h)

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/libyaml/copyright COPYONLY)
