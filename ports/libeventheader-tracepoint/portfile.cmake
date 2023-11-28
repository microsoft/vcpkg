if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_BUILD_TYPE release) # Windows port only includes headers.
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF "v${VERSION}"
    SHA512 3ef4881b66c8990afe3aab844f4e5b9dcc98b67f954027ffe60f2b868a0501f04d6bb0747021b4ffff2e984987028d641975215b7ab32d0fd710171385f0f030
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libeventheader-tracepoint"
    OPTIONS
        -DBUILD_SAMPLES=OFF
        -DBUILD_TOOLS=OFF)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME eventheader-tracepoint
        CONFIG_PATH lib/cmake/eventheader-tracepoint
        DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME eventheader-headers
    CONFIG_PATH lib/cmake/eventheader-headers)

if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
