vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 4690332f9f33bee603c78c09a3bcd0ab6a9613fe47331ea94055124ebfdf8e7ca3244336c604e40fcbb18c0534c683f291889cd5a0d0932173706f327f3f1afc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DCPPTRACE_USE_EXTERNAL_LIBDWARF=ON -DCPPTRACE_VCPKG=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "cpptrace"
    CONFIG_PATH "lib/cmake/cpptrace"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
