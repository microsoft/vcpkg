cmake_minimum_required(VERSION 3.3.0)

project(Vlpp VERSION 0.10.0.0 LANGUAGES CXX)

option(SKIP_HEADERS "Skip header installation" OFF)
option(WORKFLOW_LIBRARY "Use VlppWorkflowLibrary" OFF)
option(WORKFLOW_RUNTIME "Use VlppWorkflowRuntime" OFF)
option(WORKFLOW_COMPILER "Use VlppWorkflowCompiler" OFF)
option(GACUI "Use GacUI" OFF)
option(DARK_SKIN "Use DarkSkin" OFF)
option(REFLECTION "Use GacUIReflection or DarkSkinReflection" OFF)
cmake_dependent_option(GACUI_REFLECTION "Use GacUIReflection" ON "GACUI;REFLECTION" OFF)
cmake_dependent_option(DARK_SKIN_REFLECTION "Use GacUIReflection" ON "DARK_SKIN;REFLECTION" OFF)
option(BUILD_GACUI_COMPILER "Build GacUICompiler" OFF)

set(CMAKE_CXX_STANDARD 20)

# library
set(CORE_HDRS
    Import/Vlpp.h
    Import/VlppOS.h
    Import/VlppGlrParser.h
    Import/VlppRegex.h
)
set(CORE_SRCS
    Import/Vlpp.cpp
    Import/VlppOS.cpp
    Import/VlppGlrParser.cpp
    Import/VlppRegex.cpp
)

if (WIN32)
    list(APPEND CORE_SRCS Import/Vlpp.Windows.cpp Import/VlppOS.Windows.cpp)
else()
    list(APPEND CORE_SRCS Import/Vlpp.Linux.cpp Import/VlppOS.Linux.cpp)
endif()

if (WORKFLOW_LIBRARY)
    list(APPEND CORE_HDRS Import/VlppWorkflowLibrary.h)
    list(APPEND CORE_SRCS Import/VlppWorkflowLibrary.cpp)
endif()

if (WORKFLOW_RUNTIME)
    list(APPEND CORE_HDRS Import/VlppWorkflowRuntime.h)
    list(APPEND CORE_SRCS Import/VlppWorkflowRuntime.cpp)
endif()

if (WORKFLOW_COMPILER)
    list(APPEND CORE_HDRS Import/VlppWorkflowCompiler.h)
    list(APPEND CORE_SRCS Import/VlppWorkflowCompiler.cpp)
endif()

if (GACUI)
    set(GACUI_SRCS Import/GacUI.cpp Import/GacUI.Windows.cpp)
    if (GACUI_REFLECTION)
        list(APPEND CORE_HDRS Import/VlppReflection.h)
        list(APPEND GACUI_SRCS Import/GacUIReflection.cpp Import/VlppReflection.cpp)
    endif()
    if (NOT GACUI_REFLECTION)
        list(APPEND EXTRA_DEFINES VCZH_DEBUG_NO_REFLECTION)
    endif()
    list(APPEND CORE_SRCS ${GACUI_SRCS})
endif()

if (DARK_SKIN)
    set(DARK_SKIN_SRCS Import/Skins/DarkSkin/DarkSkin.cpp)
    if (DARK_SKIN_REFLECTION)
        list(APPEND CORE_HDRS Import/VlppReflection.h)
        list(APPEND DARK_SKIN_SRCS Import/Skins/DarkSkin/DarkSkinReflection.cpp Import/VlppReflection.cpp)
    endif()
    list(APPEND EXTRA_INCLUDES Import/Skins/DarkSkin)
    if (NOT DARK_SKIN_REFLECTION)
        list(APPEND EXTRA_DEFINES VCZH_DEBUG_NO_REFLECTION)
    endif()
    list(APPEND CORE_SRCS ${DARK_SKIN_SRCS})
endif()

list(REMOVE_DUPLICATES CORE_HDRS)
list(REMOVE_DUPLICATES CORE_SRCS)

add_library(Vlpp STATIC ${CORE_SRCS})

# target_compile_definitions
target_compile_definitions(Vlpp PRIVATE UNICODE)
target_compile_definitions(Vlpp PRIVATE _UNICODE)

if (EXTRA_DEFINES)
    target_compile_definitions(Vlpp PUBLIC ${EXTRA_DEFINES})
endif()

if(MSVC)
    target_compile_options(Vlpp PRIVATE /bigobj)
endif()

if (EXTRA_INCLUDES)
    target_include_directories(Vlpp PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/${EXTRA_INCLUDES}> $<INSTALL_INTERFACE:${EXTRA_INCLUDES}>)
endif()
target_include_directories(Vlpp PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/Import> $<INSTALL_INTERFACE:Import>)

# Tool
if (BUILD_GACUI_COMPILER)
    add_executable(GacGen Import/GacUICompiler.cpp)
    
    install(TARGETS GacGen RUNTIME DESTINATION "bin")
endif()

# Install
install(
  TARGETS Vlpp
  EXPORT unofficial-vlpp
  RUNTIME DESTINATION "bin"
  LIBRARY DESTINATION "lib"
  ARCHIVE DESTINATION "lib"
)

install(EXPORT unofficial-vlpp
    NAMESPACE unofficial::vlpp::
    DESTINATION share/unofficial-vlpp
)

if (NOT SKIP_HEADERS)
    install(FILES ${CORE_HDRS} DESTINATION "include")
endif()
