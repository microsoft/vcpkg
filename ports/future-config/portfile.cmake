vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO F-I-D-O/Future-Config
	REF v0.2.0
	SHA512 e154122a4e6bccc89ec11451be0c2528f20c9d16fa4bcfcba0c926df80cf2aaa3b5a532e6aa8261e37e4e6f518026047779d66ee788873f4d8af9f278c6b0477
	HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}/cpp"
	OPTIONS
		-D FCONFIG_BUILD_SHARED_LIBS=${BUILD_SHARED}
		-D FCONFIG_ENABLE_TESTS=OFF
		-D FCONFIG_BUILDER_COPY_LIBRARY_DEPENDENCIES_MANUALLY=OFF
		-D FCONFIG_INSTALL_BUILDER_TOOL_AND_HEADERS_DEBUG=OFF
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


