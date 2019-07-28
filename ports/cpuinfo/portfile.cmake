include(vcpkg_common_functions)

# On Windows, we can get a cpuinfo.dll, but it exports no symbols.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    pull_22_patch_file
    URLS "https://patch-diff.githubusercontent.com/raw/pytorch/cpuinfo/pull/22.patch"
    FILENAME "cpuinfo-pull-22-868bd11.patch"
    SHA512 c8fbbad1bc4a01b7c8aa10c9e395d1d9e8a1c48c95fca511bfa7ca36b69450e3804281bebcf6f2abacd92592d20abd08df26a32792eca33294380f1b8d68f9ac
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/cpuinfo
    REF d5e37adf1406cf899d7d9ec1d317c47506ccb970
    SHA512 ecd2115340fa82a67db7889ce286c3070d5ab9c30b02372b08aac893e90ccebc65c6b3e66aa02a9ae9c57892d2d8c3b77cb836e5fc3b88df2c75d33e574d90d2
    HEAD_REF master
    PATCHES
        ${pull_22_patch_file}
)

vcpkg_check_features(tools CPUINFO_BUILD_TOOLS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DCPUINFO_BUILD_TOOLS=OFF
    OPTIONS_RELEASE
        -DCPUINFO_BUILD_TOOLS=${CPUINFO_BUILD_TOOLS}
    OPTIONS
        -DCPUINFO_BUILD_UNIT_TESTS=OFF
        -DCPUINFO_BUILD_MOCK_TESTS=OFF
        -DCPUINFO_BUILD_BENCHMARKS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(CPUINFO_BUILD_TOOLS)
    if(NOT CMAKE_SYSTEM_NAME OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(EXECUTABLE_SUFFIX ".exe")
    else()
        set(EXECUTABLE_SUFFIX "")
    endif()

    foreach(cpuinfo_tool cache-info cpuid-dump cpu-info isa-info)
        file(COPY
            ${CURRENT_PACKAGES_DIR}/bin/${cpuinfo_tool}${EXECUTABLE_SUFFIX}
            DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
        )
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
    endforeach()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    else()
        message(FATAL_ERROR "FIXME")
    endif()
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
