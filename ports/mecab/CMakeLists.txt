cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

PROJECT(mecab VERSION 1.0)
                          
file(GLOB SOURCE_FILE
	"*.cpp"
	"*.c"
)
file(GLOB HEADERS_FILE
	"*.h"
)

message(STATUS "current cmake path: ${CMAKE_CURRENT_SOURCE_DIR}")
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-cost-train.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-dict-gen.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-dict-index.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-system-eval.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-test-gen.cpp)
#list(REMOVE_ITEM SOURCE_FILE "mecab-cost-train.cpp" "mecab-dict-gen.cpp" "mecab-dict-index.cpp" "mecab-system-eval.cpp" "mecab-test-gen.cpp")

add_library (mecab ${SOURCE_FILE})
target_include_directories(mecab PUBLIC
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
	$<INSTALL_INTERFACE:include>)

if(UNIX)
	target_compile_definitions(mecab PUBLIC -DHAVE_UNISTD_H -DHAVE_FCNTL_H -DHAVE_STDINT_H -DHAVE_SYS_TYPES_H -DHAVE_SYS_STAT_H -DHAVE_DIRENT_H -DDIC_VERSION=102 -DVERSION="@VERSION@" -DPACKAGE="mecab" -DMECAB_DEFAULT_RC="./mecabrc")
endif(UNIX)
if(WIN32)
	target_compile_definitions(mecab PUBLIC -D_CRT_SECURE_NO_DEPRECATE -DMECAB_USE_THREAD -DDLL_EXPORT -DHAVE_GETENV -DHAVE_WINDOWS_H -DDIC_VERSION=102 -DVERSION="@VERSION@" -DPACKAGE="mecab" -DUNICODE -D_UNICODE -DMECAB_DEFAULT_RC="mecabrc")
endif(WIN32)


include (GNUInstallDirs)
include(CMakePackageConfigHelpers)

set (mecab_CMAKE_DIR share/mecab CACHE STRING "Installation dir")
set (targets_export_name mecabTargets CACHE INTERNAL "")

install(TARGETS mecab
	EXPORT ${targets_export_name}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(FILES ${HEADERS_FILE} DESTINATION include/mecab CONFIGURATIONS Release)

install(EXPORT ${targets_export_name}
        NAMESPACE mecab::
		DESTINATION ${mecab_CMAKE_DIR})

configure_package_config_file(
	"${PROJECT_SOURCE_DIR}/Config.cmake.in"
	"${PROJECT_BINARY_DIR}/mecabConfig.cmake" 
	INSTALL_DESTINATION ${mecab_CMAKE_DIR})


write_basic_package_version_file(
  ${PROJECT_BINARY_DIR}/mecabConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion )

install(FILES 
	${PROJECT_BINARY_DIR}/mecabConfig.cmake 
	${PROJECT_BINARY_DIR}/mecabConfigVersion.cmake 
	DESTINATION ${mecab_CMAKE_DIR})
