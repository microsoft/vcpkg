cmake_minimum_required(VERSION 3.3.0)

project(Vlpp VERSION 0.10.0.0 LANGUAGES CXX)

option(SKIP_HEADERS "Skip header installation" OFF)
option(REFLECTION "Use reflection, will enable GacUIReflection or DarkSkinReflection automaticly when GacUI or DarkSkin was enabled" OFF)
cmake_dependent_option(GLR_PARSER "Use VlppGlrParser" ON "REFLECTION" OFF)
cmake_dependent_option(WORKFLOW_LIBRARY "Use VlppWorkflowLibrary" ON "REFLECTION" OFF)
cmake_dependent_option(WORKFLOW_RUNTIME "Use VlppWorkflowRuntime" ON "WORKFLOW_LIBRARY" OFF)
cmake_dependent_option(WORKFLOW_COMPILER "Use VlppWorkflowCompiler" ON "WORKFLOW_RUNTIME" OFF)
cmake_dependent_option(GACUI_CORE "Use GacUI" ON "GLR_PARSER;WORKFLOW_LIBRARY" OFF)
cmake_dependent_option(GACUI_REFLECTION "Use GacUIReflection" ON "GACUI_CORE;WORKFLOW_RUNTIME;REFLECTION" OFF)
cmake_dependent_option(GACUI_COMPILER "Use GacUICompiler" ON "GACUI_REFLECTION;WORKFLOW_COMPILER" OFF)

set(CMAKE_CXX_STANDARD 20)

# library
set(CORE_HDRS
    Import/Vlpp.h
    Import/VlppOS.h
    Import/VlppRegex.h
)
set(CORE_SRCS
    Import/Vlpp.cpp
    Import/VlppOS.cpp
    Import/VlppRegex.cpp
)

if (WIN32)
    list(APPEND CORE_SRCS Import/Vlpp.Windows.cpp Import/VlppOS.Windows.cpp)
else()
    list(APPEND CORE_SRCS Import/Vlpp.Linux.cpp Import/VlppOS.Linux.cpp)
endif()

if (REFLECTION)
    list(APPEND CORE_HDRS Import/VlppReflection.h)
    list(APPEND CORE_SRCS Import/VlppReflection.cpp)
endif()

if (GLR_PARSER)
    list(APPEND CORE_HDRS Import/VlppGlrParser.h)
    list(APPEND CORE_SRCS Import/VlppGlrParser.cpp)
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

if (GACUI_CORE)
    set(GACUI_CORE_HDRS Import/GacUI.h Import/Skins/DarkSkin/DarkSkin.h)
    if (WIN32)
        list(APPEND GACUI_CORE_HDRS Import/GacUI.Windows.h)
    endif()
    set(GACUI_CORE_SRCS Import/GacUI.cpp Import/Skins/DarkSkin/DarkSkin.cpp)
    if (WIN32)
        list(APPEND GACUI_CORE_SRCS Import/GacUI.Windows.cpp)
    endif()

    if (GACUI_REFLECTION)
        list(APPEND GACUI_CORE_HDRS Import/GacUIReflection.h Import/Skins/DarkSkin/DarkSkinReflection.h)
        list(APPEND GACUI_CORE_SRCS Import/GacUIReflection.cpp Import/Skins/DarkSkin/DarkSkinReflection.cpp)
    else()
        list(APPEND EXTRA_DEFINES VCZH_DEBUG_NO_REFLECTION)
    endif()

    if (GACUI_COMPILER)
        list(APPEND GACUI_CORE_HDRS Import/GacUICompiler.h)
        list(APPEND GACUI_CORE_SRCS Import/GacUICompiler.cpp)
    endif()
    
    list(APPEND EXTRA_INCLUDES Import/Skins/DarkSkin)

    list(APPEND CORE_HDRS ${GACUI_CORE_HDRS})
    list(APPEND CORE_SRCS ${GACUI_CORE_SRCS})
endif()

list(REMOVE_DUPLICATES CORE_HDRS)
list(REMOVE_DUPLICATES CORE_SRCS)

add_library(Vlpp STATIC ${CORE_HDRS} ${CORE_SRCS})

# target_compile_definitions
target_compile_definitions(Vlpp PRIVATE UNICODE _UNICODE)

if (EXTRA_DEFINES)
    target_compile_definitions(Vlpp PUBLIC ${EXTRA_DEFINES})
endif()

if(MSVC)
    target_compile_options(Vlpp PRIVATE /bigobj)
endif()

if (EXTRA_INCLUDES)
    foreach(EXTRA_INCLUDE_DIR IN LISTS EXTRA_INCLUDES)
        target_include_directories(Vlpp PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/${EXTRA_INCLUDE_DIR}>
            $<INSTALL_INTERFACE:${EXTRA_INCLUDE_DIR}>
        )
    endforeach()
endif()
target_include_directories(Vlpp PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/Import> $<INSTALL_INTERFACE:Import>)

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
