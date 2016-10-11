include(vcpkg_common_functions)
find_program(POWERSHELL powershell)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ChakraCore-1.2.0.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/Microsoft/ChakraCore/archive/v1.2.0.0.tar.gz"
    FILENAME "ChakraCore-1.2.0.0.tar.gz"
    SHA512 53e487028a30605a4e2589c40b65da060ca4884617fdba8877557e4db75f911be4433d260132cce3526647622bdc742a0aacda1443a16dfed3d3fdd442539528
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

message(STATUS "Patching JavascriptPromise.cpp for PR#1440...")
vcpkg_execute_required_process(
	COMMAND ${POWERSHELL} -command (gc lib/runtime/library/JavascriptPromise.cpp -encoding utf7) -replace('«', '^<^<') -replace('»', '^>^>') | Set-Content lib/runtime/library/JavascriptPromise.cpp
	WORKING_DIRECTORY ${SOURCE_PATH}
)
message(STATUS "Patching done.")

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
