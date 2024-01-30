vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF "v${VERSION}"
    SHA512 6b22ecded7029dfb9d9fba4fb76a8c25a28fbb3a6295b8ff6f66cea83d5b7645a85244126f52896065eccb9d08cbafa89dd1a23971c38842c4f752a274e5a72d
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libtracepoint-control-cpp")

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_config_fixup(
    PACKAGE_NAME tracepoint-control
    CONFIG_PATH lib/cmake/tracepoint-control)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
