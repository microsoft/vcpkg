if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ChakraCore-1.3.1)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/Microsoft/ChakraCore/archive/v1.3.1.tar.gz"
    FILENAME "ChakraCore-1.3.1.tar.gz"
    SHA512 52216a03333e44bce235917cfae5ccd6a756056678d9b81c63ec272d9ce5c6afabc673e7910dd3da54fda7927ea62ede980a4371dbb08f6ce4907121c27dbc53
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/Build/Chakra.Core.sln
)

file(INSTALL
	${SOURCE_PATH}/lib/jsrt/ChakraCore.h
	${SOURCE_PATH}/lib/jsrt/ChakraCommon.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
	${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.dll
	${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
	${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/Chakracore.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
	${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ChakraCore.dll
	${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ChakraCore.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
	${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/Chakracore.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
	${SOURCE_PATH}/LICENSE.txt
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/ChakraCore RENAME copyright)
