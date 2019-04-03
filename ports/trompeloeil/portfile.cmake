include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF v33
    SHA512 944f8ee3d2c11877e56cfef7cbcf217ce88dbf8e426a39bba4c74c00057647503394ee9736ce19b0653cd8bba83ac717ea251155e665d3810bd5aba5133ac1b3
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/trompeloeil TARGET_PATH share/trompeloeil)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include/trompeloeil.hpp)
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

configure_file(${SOURCE_PATH}/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/trompeloeil/copyright COPYONLY)
