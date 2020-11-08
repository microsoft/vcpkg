set(SEAL_VERSION_MAJOR 3)
set(SEAL_VERSION_MINOR 5)
set(SEAL_VERSION_MICRO 9)

vcpkg_fail_port_install(ON_TARGET "uwp")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SEAL_BUILD_STATIC)


if (SEAL_BUILD_STATIC)
    set(BUILD_SHARED_LIBS OFF)
endif()

if (SEAL_BUILD_DYNAMIC)
    set(BUILD_SHARED_LIBS ON)
endif()

string(TOUPPER ${PORT} PORT_UPPER)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF e8a4c2dfa3e99961ef31e162bbc7437170470ef0
    SHA512 085a081687043cbc4921ce2a64087b0dbe83b19e10edf4e508edd4d886553597a163e822dad4c28a93d6de3f0612c326beb75403abcee4b5b39435882066b1a1
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    zlib SEAL_USE_ZLIB
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DALLOW_COMMAND_LINE_BUILD=ON
        -DSEAL_USE_MSGSL=OFF # issue https://github.com/microsoft/SEAL/issues/159
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT_UPPER}-${SEAL_VERSION_MAJOR}.${SEAL_VERSION_MINOR})

file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
