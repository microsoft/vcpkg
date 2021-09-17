vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/marl
    REF 4c1b662da7d7a35f0fba9156a08cb49d129f5189 #2021-04-25
    SHA512 a3f8f65ef870075fac96dc67e8efbbe62596787a623aab02509c34f80a7cae523412d4bf94450c400a4637a0fffee6ef0cbf8f38286707e9d001e628cc11177f
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
