vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF "v${VERSION}"
    SHA512 d2126bb8e89c952630e22d66f0c9f2be7e46debd8f8dbc27f3a886af77cf4c1d9c3efcf3b7cae886feacfb9fe142355b26a3fb468c9b3582d65eb16f4dc6c288
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
