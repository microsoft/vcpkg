if(VCPKG_TARGET_IS_LINUX)	
    MESSAGE(WARNING "${PORT} requires libbluetooth-dev from the system package manager.\nTry: 'sudo yum install libbluetooth-dev ' (or sudo apt-get install libbluetooth-dev)")  
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
	REPO robotraconteur/robotraconteur
	REF "v${VERSION}"
	SHA512 6c4cf2306f632ec87d84a6e93277f907063de642d02e358c6a5384ae157cfc6e9f45d90b0a77fd1c741304c5a93d6e60c97e41d2ca64967c75075b7f760720fc
	HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
	    -DBUILD_GEN=ON
	    -DBUILD_TESTING=OFF
	    -DCMAKE_CXX_STANDARD=11
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES RobotRaconteurGen AUTO_CLEAN)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/robotraconteur)

vcpkg_cmake_config_fixup(
	PACKAGE_NAME RobotRaconteur
	CONFIG_PATH "lib/cmake/RobotRaconteur"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

