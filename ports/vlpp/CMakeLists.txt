cmake_minimum_required(VERSION 3.3.0)

project(Vlpp VERSION 0.9.3.1 LANGUAGES CXX)

# Sources
set(SRCS
  Import/Vlpp.cpp
  Import/VlppWorkflow.cpp
  Import/VlppWorkflowCompiler.cpp)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
endif()

# Create and configure the target
add_library(Vlpp ${SRCS})

# target_compile_definitions
target_compile_definitions(Vlpp PRIVATE UNICODE)
target_compile_definitions(Vlpp PRIVATE _UNICODE)

target_include_directories(Vlpp PRIVATE ${PROJECT_SOURCE_DIR}/Import)

# Install
install(
  TARGETS Vlpp
  RUNTIME DESTINATION "bin"
  LIBRARY DESTINATION "lib"
  ARCHIVE DESTINATION "lib"
  )

if (NOT DEFINED SKIP_HEADERS)
  install(
      FILES
        Import/Vlpp.h
        Import/VlppWorkflow.h
        Import/VlppWorkflowCompiler.h
      DESTINATION "include"
    )
endif()
