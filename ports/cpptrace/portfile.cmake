vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 5eec01196cb1adc16e9b596e1a6375b7cf91c7756ff271cb32331f17a54d4216efc32ccf624367ee014621ba44f0fde557eeba40089b2b64d0f108749af218d8
    HEAD_REF main
)

vcpkg_list(SET options -DCPPTRACE_USE_EXTERNAL_LIBDWARF=On -DCPPTRACE_VCPKG=On)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "cpptrace"
    CONFIG_PATH "lib/cmake/cpptrace"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
