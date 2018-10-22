include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF v32
    SHA512 001660b540880d9b1777d41ceb564b603a8d442649da86f9272e34cc642e10b43217ffadbc7d7fa7d32cb60dcc3daa0be17f86d5de48e8fce25f8681c645025d
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
