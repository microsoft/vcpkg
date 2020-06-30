vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/marl
    REF 45be9b248306e6ec3136efdd256d769c23b581d1
    SHA512 24efe143718adbf4894e21e715ef5ed2585085b7b3729d9e21d3b0951c7c939e16c9f531eb52ec489cb539d1f70a2dcde025b7bbcbb2165ddf1a5b8278f9b806
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MARL_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMARL_BUILD_SHARED=${MARL_BUILD_SHARED}
        -DMARL_INSTALL=ON
)

vcpkg_install_cmake()

if(MARL_BUILD_SHARED)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/marl/export.h"
        "#ifdef MARL_DLL"
        "#if 1  // #ifdef MARL_DLL"
    )
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
