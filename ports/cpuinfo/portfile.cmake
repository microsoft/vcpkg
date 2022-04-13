# On Windows, we can get a cpuinfo.dll, but it exports no symbols.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/cpuinfo
    REF b40bae27785787b6dd70788986fd96434cf90ae2
    SHA512 dbbe4f3e1d5ae74ffc8ba2cba0ab745a23f4993788f4947825ef5125dd1cbed3e13e0c98e020e6fcfa9879f54f06d7cba4de73ec29f77649b6a27b4ab82c8f1c
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools CPUINFO_BUILD_TOOLS
)

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

# hack to get around that toolchains/windows.cmake doesn't set CMAKE_SYSTEM_ARCHITECTURE
set(CPUINFO_TARGET_PROCESSOR_param "")
if(VCPKG_TARGET_IS_WINDOWS)
    # NOTE: arm64-windows is unsupported for now;
    # see https://github.com/pytorch/cpuinfo/pull/82 for updates
    # NOTE: arm-windows is unsupported
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(CPUINFO_TARGET_PROCESSOR_param "-DCPUINFO_TARGET_PROCESSOR=x86")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CPUINFO_TARGET_PROCESSOR_param "-DCPUINFO_TARGET_PROCESSOR=AMD64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(CPUINFO_TARGET_PROCESSOR_param "-DCPUINFO_TARGET_PROCESSOR=ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(CPUINFO_TARGET_PROCESSOR_param "-DCPUINFO_TARGET_PROCESSOR=ARM64")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${LINK_OPTIONS}
        ${CPUINFO_TARGET_PROCESSOR_param}
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES cache-info cpuid-dump cpu-info isa-info
        AUTO_CLEAN
    )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
