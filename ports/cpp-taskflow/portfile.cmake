# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF ccf1711401c5f0cced3c87806e5a348d7c2076ee  #v2.5.0
    SHA512 dac700ad5c914435e83be5ae8dc6720d43748d523c84829b19831e080f5f48c25916b029ec7f97e9898e37117087be1150d216bfe9de547131a7462cce709798
    HEAD_REF master
    PATCHES
        fix-bigobj.patch

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
