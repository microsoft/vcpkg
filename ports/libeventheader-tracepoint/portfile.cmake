if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_BUILD_TYPE release) # Windows port only includes headers.
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF "v${VERSION}"
    SHA512 baf27c967b2fa1fb8e8684951fd8e12e40fe9c23f5052a2d77c63eceab6ddfc112537422b97c37cfb0e479361fa8aedea6d8d7edfae91810f1ed696060fcb822
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libeventheader-tracepoint"
    OPTIONS
        -DBUILD_SAMPLES=OFF
)

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
