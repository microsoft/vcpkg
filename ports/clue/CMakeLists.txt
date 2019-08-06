cmake_minimum_required( VERSION 3.5)

project(clue VERSION 1.0.0 LANGUAGES CXX )

option( CLUE_BUILD_TEST     "Build tests for clue" ON )
option( CLUE_BUILD_EXAMPLE  "Build examples" ON )

include( GNUInstallDirs )
include_directories( "${CMAKE_SOURCE_DIR}/clue.hpp" )

if ( CLUE_BUILD_TEST )
  enable_testing()
  add_subdirectory( tests )
endif()

if ( CLUE_BUILD_EXAMPLE )
  enable_testing()
  add_subdirectory( examples )
endif()

install( FILES ${CMAKE_SOURCE_DIR}/clue.hpp DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} )

# end of file
