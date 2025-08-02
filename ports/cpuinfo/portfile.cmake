# On Windows, we can get a cpuinfo.dll, but it exports no symbols.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/cpuinfo
    REF e4cadd02a8b386c38b84f0a19eddacec3f433baa
    SHA512 aaf239e4a322f04514c8d85d4792abb6b4f5058be9f2013e42e51ecff66e3c967339fa3e030373aed8aebefaf8b0a287cf941de854ae7ade99fe6af4213f78e9
    HEAD_REF main
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
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/cpuid-dump${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        list(APPEND additional_tools "cpuid-dump")
    endif()
    vcpkg_copy_tools(
        TOOL_NAMES cache-info cpu-info isa-info ${additional_tools}
        AUTO_CLEAN
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
