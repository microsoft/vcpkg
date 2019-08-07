    
cmake_minimum_required(VERSION 3.8.0)
project(vcl VERSION 2.0 LANGUAGES CXX)

add_library(${PROJECT_NAME} INTERFACE)

target_include_directories(${PROJECT_NAME} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)

target_compile_features(${PROJECT_NAME} INTERFACE cxx_std_17)

add_library(${PROJECT_NAME}-detect STATIC instrset_detect.cpp)
target_link_libraries(${PROJECT_NAME}-detect PRIVATE ${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} ${PROJECT_NAME}-detect EXPORT ${PROJECT_NAME}-targets)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
    "include(\${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}-targets.cmake)")
    
include(CMakePackageConfigHelpers)
write_basic_package_version_file(${PROJECT_NAME}-config-version.cmake
    VERSION ${${PROJECT_NAME}_VERSION}
    COMPATIBILITY SameMajorVersion)
    
install(EXPORT ${PROJECT_NAME}-targets DESTINATION lib/cmake/${PROJECT_NAME}
    NAMESPACE ${PROJECT_NAME}::)
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
    DESTINATION lib/cmake/${PROJECT_NAME})
install(DIRECTORY . DESTINATION include
    FILES_MATCHING PATTERN *.h)