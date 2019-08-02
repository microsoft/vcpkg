cmake_minimum_required(VERSION 3.9)
project(casclib)

option(INSTALL_HEADERS "Install header files" ON)

set(SRC_FILES
	src/CascLib.def
	src/CascCommon.cpp
	src/CascDecompress.cpp
	src/CascDecrypt.cpp
	src/CascDumpData.cpp
	src/CascFiles.cpp
	src/CascFindFile.cpp
	src/CascIndexFiles.cpp
	src/CascOpenFile.cpp
	src/CascOpenStorage.cpp
	src/CascReadFile.cpp
	src/CascRootFile_Diablo3.cpp
	src/CascRootFile_Install.cpp
	src/CascRootFile_MNDX.cpp
	src/CascRootFile_OW.cpp
	src/CascRootFile_Text.cpp
	src/CascRootFile_TVFS.cpp
	src/CascRootFile_WoW.cpp
	src/common/Common.cpp
	src/common/Csv.cpp
	src/common/Directory.cpp
	src/common/FileStream.cpp
	src/common/FileTree.cpp
	src/common/ListFile.cpp
	src/common/RootHandler.cpp
	src/jenkins/lookup3.c
)

set(MD5_FILES
	src/md5/md5.cpp
)

set(ZLIB_FILES
	src/zlib/adler32.c
	src/zlib/crc32.c
	src/zlib/inffast.c
	src/zlib/inflate.c
	src/zlib/inftrees.c
	src/zlib/zutil.c
)

add_library(casclib ${SRC_FILES} ${TOMCRYPT_FILES} ${ZLIB_FILES} ${MD5_FILES})

if(WIN32)
	target_compile_definitions(casclib PRIVATE UNICODE _UNICODE)
endif()

set_target_properties(casclib PROPERTIES PUBLIC_HEADER "src/CascLib.h;src/CascPort.h")

if(INSTALL_HEADERS)

	install(TARGETS casclib EXPORT casclibTargets
			RUNTIME DESTINATION bin
			ARCHIVE DESTINATION lib
			LIBRARY DESTINATION lib
	)

	set(CASCLIB_VERSION "release-1.50")

	export(TARGETS casclib FILE "${PROJECT_BINARY_DIR}/casclibTargets.cmake")
	export(PACKAGE casclib)

	configure_file(casclibConfig.cmake.in        "${PROJECT_BINARY_DIR}/casclibConfig.cmake"        @ONLY)
	configure_file(casclibConfigVersion.cmake.in "${PROJECT_BINARY_DIR}/casclibConfigVersion.cmake" @ONLY)

	install(FILES
			"${PROJECT_BINARY_DIR}/casclibConfig.cmake"
			"${PROJECT_BINARY_DIR}/casclibConfigVersion.cmake"
			DESTINATION share/casclib
	)


	install(EXPORT casclibTargets DESTINATION share/casclib)
else(INSTALL_HEADERS)

	install(TARGETS casclib EXPORT casclib
			RUNTIME DESTINATION bin
			ARCHIVE DESTINATION lib
			LIBRARY DESTINATION lib
	)
endif(INSTALL_HEADERS)