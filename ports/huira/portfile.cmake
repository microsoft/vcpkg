# portfile.cmake for huira
#
# vcpkg install huira

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO huira-render/huira
    REF "v${VERSION}"
    SHA512 7f46d1c514a4a7ba5981dd2224ff4b01b3dc8f30903cf91f3bde25135d338dd7ac375d68eb75502d26264f7c6e54195c6126487cfc51c0a7c87f7c53d49df30f
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DHUIRA_APPS=ON          # build CLI tools → installed to tools/huira/
        -DHUIRA_TESTS=OFF        # never build tests in a port
)

vcpkg_cmake_install()

# Relocate CLI tools from bin/ to the vcpkg-conventional tools directory.
# List every executable your project installs.
set(HUIRA_TOOLS
    huira
)

# vcpkg_copy_tools also registers the tools so vcpkg add-path knows about them.
vcpkg_copy_tools(
    TOOL_NAMES ${HUIRA_TOOLS}
    AUTO_CLEAN
)

# Fix up the installed CMake config so that paths are relocatable.
vcpkg_cmake_config_fixup(
    PACKAGE_NAME huira
    CONFIG_PATH lib/cmake/huira
)

# Cleanup
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/bin"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/bin"
)

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Install the license. Adjust the filename to match your project.
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
