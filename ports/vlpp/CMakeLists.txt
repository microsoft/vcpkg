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

# core library
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

add_library(vlpp INTERFACE ${CORE_HDRS} ${CORE_SRCS})

target_compile_features(vlpp INTERFACE cxx_std_20)

target_compile_definitions(vlpp INTERFACE UNICODE _UNICODE)

if (EXTRA_DEFINES)
    target_compile_definitions(vlpp INTERFACE ${EXTRA_DEFINES})
endif()

if(MSVC)
    target_compile_options(vlpp INTERFACE /bigobj)
endif()

target_include_directories(vlpp INTERFACE $<INSTALL_INTERFACE:include>)

list(APPEND EXPORT_TARGETS vlpp)

if (REFLECTION)
    list(APPEND REFLECTION_HDRS Import/VlppReflection.h)
    list(APPEND REFLECTION_SRCS Import/VlppReflection.cpp)

    add_library(reflection INTERFACE ${REFLECTION_SRCS} ${REFLECTION_HDRS})
    target_link_libraries(reflection INTERFACE vlpp)

    list(APPEND EXPORT_TARGETS reflection)
endif()

if (GLR_PARSER)
    list(APPEND GLR_PARSER_HDRS Import/VlppGlrParser.h)
    list(APPEND GLR_PARSER_SRCS Import/VlppGlrParser.cpp)

    add_library(glr_parser INTERFACE ${GLR_PARSER_SRCS} ${GLR_PARSER_HDRS})
    target_link_libraries(glr_parser INTERFACE reflection)

    list(APPEND EXPORT_TARGETS glr_parser)
endif()

if (WORKFLOW_LIBRARY)
    list(APPEND WORKFLOW_LIBRARY_HDRS Import/VlppWorkflowLibrary.h)
    list(APPEND WORKFLOW_LIBRARY_SRCS Import/VlppWorkflowLibrary.cpp)

    add_library(workflow_library INTERFACE ${WORKFLOW_LIBRARY_SRCS} ${WORKFLOW_LIBRARY_HDRS})
    target_link_libraries(workflow_library INTERFACE reflection)

    list(APPEND EXPORT_TARGETS workflow_library)
endif()

if (WORKFLOW_RUNTIME)
    list(APPEND WORKFLOW_RUNTIME_HDRS Import/VlppWorkflowRuntime.h)
    list(APPEND WORKFLOW_RUNTIME_SRCS Import/VlppWorkflowRuntime.cpp)

    add_library(workflow_runtime INTERFACE ${WORKFLOW_RUNTIME_SRCS} ${WORKFLOW_RUNTIME_HDRS})
    target_link_libraries(workflow_runtime INTERFACE workflow_library)

    list(APPEND EXPORT_TARGETS workflow_runtime)
endif()

if (WORKFLOW_COMPILER)
    list(APPEND WORKFLOW_COMPILER_HDRS Import/VlppWorkflowCompiler.h)
    list(APPEND WORKFLOW_COMPILER_SRCS Import/VlppWorkflowCompiler.cpp)

    add_library(workflow_compiler INTERFACE ${WORKFLOW_COMPILER_SRCS} ${WORKFLOW_COMPILER_HDRS})
    target_link_libraries(workflow_compiler INTERFACE workflow_runtime)

    list(APPEND EXPORT_TARGETS workflow_compiler)
endif()

if (GACUI_CORE)
    list(APPEND GACUI_CORE_HDRS Import/GacUI.h Import/Skins/DarkSkin/DarkSkin.h)
    if (WIN32)
        list(APPEND GACUI_CORE_HDRS Import/GacUI.Windows.h)
    endif()
    list(APPEND GACUI_CORE_SRCS Import/GacUI.cpp Import/Skins/DarkSkin/DarkSkin.cpp)
    if (WIN32)
        list(APPEND GACUI_CORE_SRCS Import/GacUI.Windows.cpp)
    endif()

    add_library(gacui_core INTERFACE ${GACUI_CORE_SRCS} ${GACUI_CORE_HDRS})
    target_link_libraries(gacui_core INTERFACE glr_parser workflow_library)

    if (GACUI_REFLECTION)
        list(APPEND GACUI_REFLECTION_HDRS Import/GacUIReflection.h Import/Skins/DarkSkin/DarkSkinReflection.h)
        list(APPEND GACUI_REFLECTION_SRCS Import/GacUIReflection.cpp Import/Skins/DarkSkin/DarkSkinReflection.cpp)

        add_library(gacui_reflection INTERFACE ${GACUI_REFLECTION_SRCS} ${GACUI_REFLECTION_HDRS})
        target_link_libraries(gacui_reflection INTERFACE gacui_core workflow_runtime reflection)

        list(APPEND EXPORT_TARGETS gacui_reflection)
    else()
        target_compile_definitions(gacui_core INTERFACE VCZH_DEBUG_NO_REFLECTION)
    endif()

    if (GACUI_COMPILER)
        list(APPEND GACUI_COMPILER_HDRS Import/GacUICompiler.h)
        list(APPEND GACUI_COMPILER_SRCS Import/GacUICompiler.cpp)

        add_library(gacui_compiler INTERFACE ${GACUI_COMPILER_SRCS} ${GACUI_COMPILER_HDRS})
        target_link_libraries(gacui_compiler INTERFACE reflection workflow_compiler)

        list(APPEND EXPORT_TARGETS gacui_compiler)
    endif()
    
    target_include_directories(gacui_core INTERFACE $<INSTALL_INTERFACE:include/Skins/DarkSkin>)

    list(APPEND EXPORT_TARGETS gacui_core)
endif()

# Install
install(
  TARGETS ${EXPORT_TARGETS}
  EXPORT unofficial-vlpp
  RUNTIME DESTINATION "bin"
  LIBRARY DESTINATION "lib"
  ARCHIVE DESTINATION "lib"
)

install(EXPORT unofficial-vlpp
    NAMESPACE unofficial::vlpp::
    FILE unofficial-vlppConfig.cmake
    DESTINATION share/unofficial-vlpp
)

if (NOT SKIP_HEADERS)
    install(FILES ${CORE_HDRS} DESTINATION include)
    
    if (REFLECTION)
        install(FILES ${REFLECTION_HDRS} DESTINATION include)
    endif()

    if (GLR_PARSER)
        install(FILES ${GLR_PARSER_HDRS} DESTINATION include)
    endif()
    
    if (WORKFLOW_LIBRARY)
        install(FILES ${WORKFLOW_LIBRARY_HDRS} DESTINATION include)
    endif()
    
    if (WORKFLOW_RUNTIME)
        install(FILES ${WORKFLOW_RUNTIME_HDRS} DESTINATION include)
    endif()
    
    if (WORKFLOW_COMPILER)
        install(FILES ${WORKFLOW_COMPILER_HDRS} DESTINATION include)
    endif()
    
    if (GACUI_CORE)
        install(FILES Import/GacUI.h DESTINATION include)
        install(FILES Import/Skins/DarkSkin/DarkSkin.h DESTINATION include/Skins/DarkSkin)
    
        if (GACUI_REFLECTION)
            install(FILES Import/GacUIReflection.h DESTINATION include)
            install(FILES Import/Skins/DarkSkin/DarkSkinReflection.h DESTINATION include/Skins/DarkSkin)
        endif()
        
        if (GACUI_COMPILER)
            install(FILES ${GACUI_COMPILER_HDRS} DESTINATION include)
        endif()
    endif()
endif()
