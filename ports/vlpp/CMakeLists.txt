cmake_minimum_required(VERSION 3.3.0)

project(Vlpp VERSION 0.10.0.0 LANGUAGES CXX)

option(SKIP_HEADERS "Skip header installation" OFF)

# Sources
set(SRCS
  Import/Vlpp.cpp
  Import/VlppWorkflowLibrary.cpp
  Import/VlppWorkflowCompiler.cpp
  Import/VlppWorkflowRuntime.cpp)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
endif()

if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 14)
endif()

# Create and configure the target
add_library(Vlpp INTERFACE ${SRCS})

# target_compile_definitions
target_compile_definitions(Vlpp INTERFACE UNICODE)
target_compile_definitions(Vlpp INTERFACE _UNICODE)

target_include_directories(Vlpp INTERFACE $<INSTALL_INTERFACE:Import>)

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
  install(
      FILES
        Import/Vlpp.h
        Import/VlppWorkflowLibrary.h
        Import/VlppWorkflowCompiler.h
        Import/VlppWorkflowRuntime.h
      DESTINATION "include"
    )
endif()
