cmake_minimum_required(VERSION 3.9)

project(casclib)
set(PROJECT_VERSION_MAJOR 1)
set(PROJECT_VERSION_MINOR 50)

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

add_library(casclib ${SRC_FILES} ${ZLIB_FILES} ${MD5_FILES})
target_include_directories(casclib 
                           PUBLIC 
                               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                               $<INSTALL_INTERFACE:include/casclib>)
if(WIN32)
    target_compile_definitions(casclib PRIVATE UNICODE _UNICODE)
endif()

install(TARGETS casclib 
        EXPORT casclibTargets
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
)

include(CMakePackageConfigHelpers)

set(VERSION_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/temp/casclibConfigVersion.cmake")
set(PROJECT_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/temp/casclibConfig.cmake")
set(INSTALL_DIR "share/casclib")

write_basic_package_version_file("${VERSION_CONFIG}" VERSION 1.50 COMPATIBILITY SameMajorVersion)
configure_package_config_file("Config.cmake.in"
                              "${PROJECT_CONFIG}"
                              INSTALL_DESTINATION "${INSTALL_DIR}")

install(FILES "${PROJECT_CONFIG}" "${VERSION_CONFIG}" DESTINATION "${INSTALL_DIR}")
install(EXPORT casclibTargets DESTINATION "${INSTALL_DIR}")

if(INSTALL_HEADERS)
    install(FILES "src/CascLib.h" "src/CascPort.h" DESTINATION include/casclib)
endif()
