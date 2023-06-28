vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF 3173fa8180eb5bb7167a686c8c18baf8ef0bf31b
    SHA512 9bd2e16da96e37df58e4281d1341051eb90574cb29d380f04f90bba7507dc9b3037ded91206d5e1808b53734fc0fc1fd06c4a220b0f34d0078ac168e6c639462
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
