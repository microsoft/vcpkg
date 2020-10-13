include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF 08cba57ed7207c8ad5c94fd2a20dc0bfecabe878 # v38
    SHA512 b51626eb263f971f1ed6e29d86256adde19f9f60487e00a6098933de37d0a1cb64b6d797447fcde6f5121a1b29f39bd7b6aed8f5889450d72ef6a76d46eb921f
    HEAD_REF master
    PATCHES disable_master_project.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/trompeloeil)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include/trompeloeil.hpp)
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

configure_file(${SOURCE_PATH}/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/trompeloeil/copyright COPYONLY)
