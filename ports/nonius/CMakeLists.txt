cmake_minimum_required(VERSION 3.9)
cmake_policy(VERSION ${CMAKE_VERSION}) # use default policies of current cmake version

project(nonius)

add_library(nonius INTERFACE)
target_include_directories(nonius INTERFACE  
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> 
    $<INSTALL_INTERFACE:include> 
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION include
  )
endif()

install(TARGETS nonius
    EXPORT noniusExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT noniusExport
    FILE noniusConfig.cmake
    NAMESPACE Nonius::
    DESTINATION share/nonius
)
