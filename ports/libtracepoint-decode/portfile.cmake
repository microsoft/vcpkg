vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF abf1f6d3e32546aeaab75ed3cea45b54b94fbd50
    SHA512 ac67bbd8184a29c8058a7b2cde51db9a14f97326396ba894f56a36d4219bebbc580f64a3ed5f182df4a0111ad97294a6b780bd44181d37e0fda1be16a6e23dea
    HEAD_REF main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libtracepoint-decode-cpp")

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_config_fixup(
    PACKAGE_NAME tracepoint-decode
    CONFIG_PATH lib/cmake/tracepoint-decode)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
