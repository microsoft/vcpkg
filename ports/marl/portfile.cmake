include(vcpkg_common_functions)

if(VCPKG_TARGET_IS_UWP)
    message(FATAL_ERROR "This port doesn't support UWP currently!")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/marl
    REF bf3e23083979c3bd3de1c77346b655eec423b3bc
    SHA512 8c85b9a2b7e3cb397fc11c4bf32c5f62d4113ab6af92861c93472299f1b9296edef4dd8d1eb24db242fe55b52f33d2e058a4ce91fbaa793ffa4d5f4c8e336251
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMARL_INSTALL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
