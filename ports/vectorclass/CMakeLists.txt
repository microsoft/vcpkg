    
cmake_minimum_required(VERSION 3.8.0)
project(vectorclass VERSION 2.0 LANGUAGES CXX)

add_library(${PROJECT_NAME} STATIC instrset_detect.cpp)

target_include_directories(${PROJECT_NAME} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}>)

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)

install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}-targets)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake.in"
    "@PACKAGE_INIT@ \ninclude(@CONFIG_INSTALL_DIR@${PROJECT_NAME}-targets.cmake)")

include(CMakePackageConfigHelpers)
configure_package_config_file("${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake.in"
			      "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
				INSTALL_DESTINATION lib/cmake/${PROJECT_NAME})


write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
    VERSION ${${PROJECT_NAME}_VERSION}
    COMPATIBILITY SameMajorVersion)
    
install(EXPORT ${PROJECT_NAME}-targets DESTINATION lib/cmake/${PROJECT_NAME}
    NAMESPACE ${PROJECT_NAME}::)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
    DESTINATION lib/cmake/${PROJECT_NAME})
install(DIRECTORY . DESTINATION include/${PROJECT_NAME}
    FILES_MATCHING PATTERN *.h)