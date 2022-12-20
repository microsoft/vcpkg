# On Windows, we can get a cpuinfo.dll, but it exports no symbols.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/cpuinfo
    REF 5e63739504f0f8e18e941bd63b2d6d42536c7d90
    SHA512 6a61f4574661a55771c2ec31bb0919a51d0bd8c770477b254a5c14dc5323716af275c7fe3abc5aa96720d7cc929559ca66f614265d3940e076b8db2fa15c8e36
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools CPUINFO_BUILD_TOOLS
)

set(LINK_OPTIONS "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND LINK_OPTIONS -DCPUINFO_LIBRARY_TYPE=shared)
else()
    list(APPEND LINK_OPTIONS -DCPUINFO_LIBRARY_TYPE=static)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND LINK_OPTIONS -DCPUINFO_RUNTIME_TYPE=shared)
else()
    list(APPEND LINK_OPTIONS -DCPUINFO_RUNTIME_TYPE=static)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${LINK_OPTIONS}
        -DCPUINFO_BUILD_UNIT_TESTS=OFF
        -DCPUINFO_BUILD_MOCK_TESTS=OFF
        -DCPUINFO_BUILD_BENCHMARKS=OFF
    OPTIONS_DEBUG
        -DCPUINFO_LOG_LEVEL=debug
    OPTIONS_RELEASE
        -DCPUINFO_LOG_LEVEL=default
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig() # pkg_check_modules(libcpuinfo)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if("tools" IN_LIST FEATURES)
    set(additional_tools "")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/cpuid-dump")
        list(APPEND additional_tools "cpuid-dump")
    endif()
    vcpkg_copy_tools(
        TOOL_NAMES cache-info cpu-info isa-info ${additional_tools}
        AUTO_CLEAN
    )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
