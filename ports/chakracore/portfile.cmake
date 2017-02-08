if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ChakraCore-1.4.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/Microsoft/ChakraCore/archive/v1.4.0.tar.gz"
    FILENAME "ChakraCore-1.4.0.tar.gz"
    SHA512 d515d56ff1c5776ca4663e27daa4d1c7ca58c57f097799de756980771b5701e35639eefa4db5921d7327e6607b8920df3b30677eb467123e04536df0d971cebc
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
