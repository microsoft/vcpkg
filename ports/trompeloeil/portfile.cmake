include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF v34
    SHA512 0fffdb38287699c413e35d541e14ddf2e355a0a3df3b3f7be3a56d02f012571af1f4cad3de0a23863ab9b70aa75d2a7ef0227f3896195a51c04ccf817fe1c9dc
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
