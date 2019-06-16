include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
	REPO robotraconteur/robotraconteur
	REF v0.9.0
	SHA512 f34ee198f78d2319714e9b8712e4e6a6ee279109ac3ae4bf9ee90d1e7236ceaaba4fba7c4305976b8d5f53da52f94e8bbc16f21279ed7339483b53977385e7e1
	HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
	    -DBUILD_GEN=ON
		-DRobotRaconteur_USE_SHARED_LIB=ON
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/robotraconteur")

file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/RobotRaconteurGen.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/robotraconteur)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/robotraconteur)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/RobotRaconteur")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/robotraconteur/copyright)