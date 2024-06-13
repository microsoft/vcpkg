if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_BUILD_TYPE release) # Windows port only includes headers.
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF "v${VERSION}"
    SHA512 b296ad3ee102d45cd8bccb2e3ed478f3d7adff8b3650251926189fd6efbca38728db61208af1627c08c16641b349e31e9366c6bc1965795063f39a167181f067
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libtracepoint"
    OPTIONS
        -DBUILD_SAMPLES=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_TESTS=OFF)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME tracepoint
        CONFIG_PATH lib/cmake/tracepoint
        DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME tracepoint-headers
    CONFIG_PATH lib/cmake/tracepoint-headers)

if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
