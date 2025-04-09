vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO F-I-D-O/Future-Config
  REF "v${VERSION}"
  SHA512 bbb6ce397963c15f71d4c10b14a69d8047ff6e49eaf1ad65de840cce96cee459a9145b0257a53a0a4ddab6f35122d3fd9fbad125503e16b23a6a7907a0bee5c7
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/cpp"
  OPTIONS
    -DFCONFIG_BUILD_SHARED_LIBS=${BUILD_SHARED}
    -DFCONFIG_ENABLE_TESTS=OFF
    -DFCONFIG_BUILDER_COPY_LIBRARY_DEPENDENCIES_MANUALLY=OFF
    -DFCONFIG_INSTALL_BUILDER_TOOL_AND_HEADERS_DEBUG=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

# move the jinja template for the builder tool from bin directory to tools directory
set(BIN_DIR "${CURRENT_PACKAGES_DIR}/bin")
set(BIN_DATA_DIR "${BIN_DIR}/data")
set(PORT_TOOL_DATA_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}/data")
file(MAKE_DIRECTORY "${PORT_TOOL_DATA_DIR}")
file(RENAME "${BIN_DATA_DIR}/config.jinja" "${PORT_TOOL_DATA_DIR}/config.jinja")
file(REMOVE_RECURSE "${BIN_DATA_DIR}")

# Copy the builder tool dependencies
vcpkg_copy_tools(
  TOOL_NAMES fconfig_builder
  AUTO_CLEAN
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
