include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF mlpack-3.0.4
    SHA512 07730a826efb55a41fce2286de8df15421e7a7189b9cdc4699c6a32e3d4b1964a98e3829a60513994ef747640952229e7a3b744ac0ae324f5e5e57f982a86f66
    HEAD_REF master
	PATCHES 
		meta_info_extractor.patch
		cmakelists.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MLPACK_SHARED_LIBS)

set(BUILD_TOOLS OFF)
if("tools" IN_LIST FEATURES)
    set(BUILD_TOOLS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
		-DBUILD_TESTS=${BUILD_TOOLS}
		-DBUILD_CLI_EXECUTABLES=${BUILD_TOOLS}
		-DBUILD_SHARED_LIBS=${MLPACK_SHARED_LIBS}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/mlpack RENAME copyright)

if(BUILD_TOOLS)
	file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
	file(GLOB MLPACK_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
	file(COPY ${MLPACK_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
	file(REMOVE ${MLPACK_TOOLS})
	file(GLOB MLPACK_TOOLS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
	file(REMOVE ${MLPACK_TOOLS_DEBUG})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
