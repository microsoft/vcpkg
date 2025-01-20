vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO F-I-D-O/Future-Config
	REF v0.1.0
	SHA512 0ecaaa10c9a8c81183faa5a4722464551cdd584089fafbe01dc4d628dfb4a659363ae08e6ec6910d4adc6077f487cada2c55c6e4b37392c75a45b41886d54e1d
	HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}/cpp
	OPTIONS
		-DFCONFIG_BUILD_SHARED_LIBS=${BUILD_SHARED}
		-DFCONFIG_ENABLE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

# Copy the builder tool dependencies
vcpkg_copy_tools(
	TOOL_NAMES fconfig_builder
	AUTO_CLEAN
)

# move the jinja template for the builder tool from bin directory to tools directory
set(BIN_DIR "${CURRENT_PACKAGES_DIR}/bin")
set(BIN_DATA_DIR "${BIN_DIR}/data")
set(PORT_TOOL_DATA_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}/data")
file(MAKE_DIRECTORY "${PORT_TOOL_DATA_DIR}")
file(RENAME "${BIN_DATA_DIR}/config.jinja" "${PORT_TOOL_DATA_DIR}/config.jinja")
file(REMOVE_RECURSE "${BIN_DATA_DIR}")
# also delete the bin directory if it is empty
file(GLOB dir_to_rm_content "${BIN_DIR}/*")
if("${dir_to_rm_content}" STREQUAL "")
	file(REMOVE_RECURSE "${BIN_DIR}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

# copy the usage example
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")


