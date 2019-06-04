cmake_minimum_required(VERSION 3.9)
project(CascLib)

set(HEADER_FILES
    src/CascCommon.h
    src/CascLib.h
    src/CascLib.def
    src/CascPort.h
    src/common/Array.h
    src/common/Common.h
    src/common/Csv.h
    src/common/FileStream.h
    src/common/FileTree.h
    src/common/ListFile.h
    src/common/Map.h
    src/jenkins/lookup.h
)

set(SRC_FILES
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

if(WIN32)
    add_definitions(-DUNICODE -D_UNICODE)
endif()

add_library(CascLib ${SRC_FILES} ${HEADER_FILES} ${TOMCRYPT_FILES} ${ZLIB_FILES} ${MD5_FILES})

set_target_properties(CascLib PROPERTIES PUBLIC_HEADER "src/CascLib.h;src/CascPort.h")

install(TARGETS CascLib
	RUNTIME DESTINATION bin 
	LIBRARY DESTINATION lib 
	ARCHIVE DESTINATION lib 
	FRAMEWORK DESTINATION /Library/Frameworks
	PUBLIC_HEADER DESTINATION include
	INCLUDES DESTINATION include)