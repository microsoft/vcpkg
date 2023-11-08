vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF "v${VERSION}"
    SHA512 3ef4881b66c8990afe3aab844f4e5b9dcc98b67f954027ffe60f2b868a0501f04d6bb0747021b4ffff2e984987028d641975215b7ab32d0fd710171385f0f030
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
