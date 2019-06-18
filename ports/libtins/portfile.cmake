include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/libtins
    REF v4.0
    SHA512 8a497617ca68f4bad331452778b92c51ce87e42d1ceae493ecd6799cabbe71609214ca962c4a8c83d205f76277f2a82f92d3d17341984caa1592cf237eb3cf3b
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBTINS_BUILD_SHARED)

set(ENABLE_PCAP FALSE)
if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(ENABLE_PCAP TRUE)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBTINS_BUILD_SHARED=${LIBTINS_BUILD_SHARED}
        -DLIBTINS_ENABLE_PCAP=${ENABLE_PCAP}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/libtins/copyright COPYONLY)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME libtins)
