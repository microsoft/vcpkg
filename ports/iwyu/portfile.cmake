set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO include-what-you-use/include-what-you-use
    REF clang_8.0
    SHA512 e75e91ce198b1ec446ed34afcf9fdbcb0534c5edc5346e4884f0f589c73512d778c428aa71c1b109d45a45543a952438610ab21e32ef1f03ff1a014823ed8425
    HEAD_REF master
	)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    )
	
vcpkg_build_cmake()
vcpkg_install_cmake()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)

# license
file(COPY ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/iwyu)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/iwyu/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/iwyu/copyright)


# copy tools
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/iwyu)
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
#file(REMOVE ${BINARY_TOOLS})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/iwyu)




