if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_BUILD_TYPE release) # Windows port only includes headers.
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF f3a5b3e4c12a19924a4d6fc30a7681742fd7eb01
    SHA512 f94a3cf1367ec4749f40217923f1158da40caaf5cd75529d1ca9a5e8b51c581f0aec286f715a88b6203f9979a2e32ad69efde1738a12fa71a0301b8ddbfcc6e4
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libtracepoint"
    OPTIONS
        -DBUILD_SAMPLES=OFF
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
