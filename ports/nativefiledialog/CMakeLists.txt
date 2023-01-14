cmake_minimum_required(VERSION 3.14)

project(nfd LANGUAGES C)

include(GNUInstallDirs)

option(NFD_GTK_BACKEND "Using GTK backend" ON)

file(GLOB nfd_sources
    "${PROJECT_SOURCE_DIR}/src/*.h"
    "${PROJECT_SOURCE_DIR}/src/include/*.h"
    "${PROJECT_SOURCE_DIR}/src/nfd_common.c"
)

if (WIN32)
    enable_language(CXX)
    list(APPEND nfd_sources "${PROJECT_SOURCE_DIR}/src/nfd_win.cpp")
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    if (NFD_GTK_BACKEND)
        find_package(GTK3 QUIET)
        if (GTK3_FOUND)
            list(APPEND nfd_sources "${PROJECT_SOURCE_DIR}/src/nfd_gtk.c")
        else ()
            list(APPEND nfd_sources "${PROJECT_SOURCE_DIR}/src/nfd_zenity.c")
        endif ()
    else ()
        list(APPEND nfd_sources "${PROJECT_SOURCE_DIR}/src/nfd_zenity.c")
    endif ()
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    list(APPEND nfd_sources "${PROJECT_SOURCE_DIR}/src/nfd_cocoa.m")
endif ()

add_library(nfd ${nfd_sources})

set_target_properties(
    nfd
    PROPERTIES
        DEBUG_POSTFIX "_d"
        PUBLIC_HEADER ${CMAKE_CURRENT_LIST_DIR}/src/include/nfd.h
)

target_compile_definitions(
    nfd
    PRIVATE
        $<$<C_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>
)

target_include_directories(nfd PRIVATE
        $<BUILD_INTERFACE:
			${CMAKE_CURRENT_LIST_DIR}/src 
			${CMAKE_CURRENT_LIST_DIR}/src/include
		>)
		
target_include_directories(nfd INTERFACE 
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

if (GTK3_FOUND)
    target_include_directories(nfd PUBLIC ${GTK3_INCLUDE_DIRS})
    target_link_libraries(nfd PUBLIC ${GTK3_LIBRARIES})
endif ()

install(TARGETS nfd EXPORT unofficial-nativefiledialog-config)

install(
    EXPORT unofficial-nativefiledialog-config
    NAMESPACE unofficial::nativefiledialog::
    DESTINATION share/unofficial-nativefiledialog
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
