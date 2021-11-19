vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF f16ac13090902373e3e3c9deef064659a3c9215e
    SHA512 07857a6aae4116a51b776af7ba4ede12c1f479b535b5b8b2e373e73eac718b367e84eb87b60faeb1174be0562d35ac78f36469f2128294c028a96ecb181580eb
    HEAD_REF master
    PATCHES
        001-fix-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/kubernetes
)

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)