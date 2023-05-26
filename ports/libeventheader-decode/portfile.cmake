vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF f3a5b3e4c12a19924a4d6fc30a7681742fd7eb01
    SHA512 f94a3cf1367ec4749f40217923f1158da40caaf5cd75529d1ca9a5e8b51c581f0aec286f715a88b6203f9979a2e32ad69efde1738a12fa71a0301b8ddbfcc6e4
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libeventheader-decode-cpp"
    OPTIONS
        -DBUILD_SAMPLES=OFF
        -DBUILD_TOOLS=OFF)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_config_fixup(
    PACKAGE_NAME eventheader-decode
    CONFIG_PATH lib/cmake/eventheader-decode)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
