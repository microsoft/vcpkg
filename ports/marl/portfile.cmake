vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/marl
    REF f1c446ccdc0c611d1aeec4a6266a77693ae48c92
    SHA512 3cbe911ddc42c1996ad467958d1e3b34080a49965c3c7ce3408f59039f477c660df323cf1aa9d55447e6f54c23fd2cb19f149b722a1b66836e24bd3368fa4f46
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
