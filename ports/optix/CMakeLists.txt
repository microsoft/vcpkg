cmake_minimum_required(VERSION 3.12)
project(OptiX LANGUAGES CXX)

add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
)

install(
  TARGETS ${PROJECT_NAME} 
  EXPORT unofficial-${PROJECT_NAME}-target
)
install(
  DIRECTORY include/ 
  DESTINATION include
)
install(
  EXPORT unofficial-${PROJECT_NAME}-target 
  NAMESPACE unofficial::${PROJECT_NAME}:: 
  FILE unofficial-${PROJECT_NAME}-config.cmake
  DESTINATION share/unofficial-${PROJECT_NAME}
)
