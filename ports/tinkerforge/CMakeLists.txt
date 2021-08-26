cmake_minimum_required (VERSION 3.13 FATAL_ERROR)
include(GNUInstallDirs)

if(WIN32)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}")
endif()

project(tinkerforge LANGUAGES C VERSION 2.1.25)

if(NOT CONFIG_INSTALL_DIR)
    set(CONFIG_INSTALL_DIR "share/${PROJECT_NAME}/")
endif()
if(NOT INCLUDE_INSTALL_DIR)
    set(INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}")
endif()
if(NOT TARGET_INSTALL_DIR)
    set(TARGET_INSTALL_DIR "share/${PROJECT_NAME}")
endif()


file(GLOB CPP_FILES source/*.c)
file(GLOB H_FILES source/*.h)
file(GLOB DEF_FILE source/*.def)

add_library(${PROJECT_NAME} ${CPP_FILES} ${H_FILES} ${DEF_FILE})
target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source>
    $<INSTALL_INTERFACE:${INCLUDE_INSTALL_DIR}/${PROJECT_NAME}>)
    
find_package(Threads)
target_link_libraries(${PROJECT_NAME} PUBLIC Threads::Threads)

if("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    target_link_libraries(${PROJECT_NAME} PUBLIC Ws2_32 advapi32)
endif()
##---------------------------------------------------------------------------------------##
##----- Package definition. 
##---------------------------------------------------------------------------------------##
include(CMakePackageConfigHelpers)

#Export as Package
set_target_properties (${PROJECT_NAME} PROPERTIES EXPORT_NAME ${PROJECT_NAME})
export(TARGETS ${PROJECT_NAME} NAMESPACE ${PROJECT_NAME}:: FILE cmake/${PROJECT_NAME}Targets.cmake)
export(PACKAGE ${PROJECT_NAME})

#Config files for find_package
configure_package_config_file(
    ${PROJECT_NAME}Config.cmake.in cmake/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}/${PROJECT_NAME}Config.cmake"
    PATH_VARS TARGET_INSTALL_DIR INCLUDE_INSTALL_DIR
)
write_basic_package_version_file(cmake/${PROJECT_NAME}ConfigVersion.cmake COMPATIBILITY SameMinorVersion)

#Install the target and all it build outputs.
install (TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Targets 
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT Runtime
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT Development
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT Runtime
    PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}" COMPONENT Development
    BUNDLE DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT Runtime)
#Install public headers
install(FILES ${H_FILES} DESTINATION "${INCLUDE_INSTALL_DIR}/${PROJECT_NAME}")
#Install the config files for find_package
install(FILES "${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}ConfigVersion.cmake"
              "${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}Config.cmake"
        DESTINATION "${CONFIG_INSTALL_DIR}")
#install the targets file included by the config
install(EXPORT ${PROJECT_NAME}Targets NAMESPACE ${PROJECT_NAME}:: DESTINATION "${TARGET_INSTALL_DIR}")