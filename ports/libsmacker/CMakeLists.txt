cmake_minimum_required(VERSION 3.20)
project(libsmacker C)

option(LIBSMACKER_BUILD_TOOLS "Build smk2avi and driver executables" OFF)

add_library(libsmacker smacker.c)

if(WIN32 AND BUILD_SHARED_LIBS)
    target_sources(libsmacker PRIVATE smacker.def)
endif()

if(MSVC)
    target_compile_definitions(libsmacker PRIVATE -D_CRT_SECURE_NO_WARNINGS)
endif()

target_include_directories(libsmacker PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
set_target_properties(libsmacker PROPERTIES PUBLIC_HEADER "smacker.h")

install(TARGETS libsmacker
    EXPORT libsmackerTargets
    PUBLIC_HEADER DESTINATION include
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT libsmackerTargets
    FILE unofficial-libsmacker-config.cmake
    NAMESPACE unofficial::libsmacker::
    DESTINATION share/unofficial-libsmacker
)

if(LIBSMACKER_BUILD_TOOLS)
    add_executable(driver driver.c)
    target_include_directories(driver PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
    target_link_libraries(driver libsmacker)
    install(TARGETS driver RUNTIME DESTINATION bin)

    add_executable(smk2avi smk2avi.c)
    target_include_directories(driver PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
    target_link_libraries(smk2avi libsmacker)
    install(TARGETS smk2avi RUNTIME DESTINATION bin)
endif()
