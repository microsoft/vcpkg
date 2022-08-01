cmake_minimum_required(VERSION 3.5)

project(EDFlib VERSION 1.21.0 LANGUAGES C)

option(BUILD_TOOLS "Build EDFlib tools." OFF)

include(GNUInstallDirs)

set(sources edflib.h edflib.c)

add_library(EDFlib ${sources})

set_target_properties(EDFlib PROPERTIES PUBLIC_HEADER edflib.h)

install(TARGETS EDFlib
    EXPORT EDFlibTargets
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

install(EXPORT EDFlibTargets
    FILE unofficial-EDFlibConfig.cmake
    DESTINATION "share/unofficial-EDFlib"
)

if(BUILD_TOOLS)
    add_executable(sine_generator sine_generator.c)
    target_link_libraries(sine_generator PRIVATE EDFlib)

    add_executable(sweep_generator sweep_generator.c)
    target_link_libraries(sweep_generator PRIVATE EDFlib)

    add_executable(test_edflib test_edflib.c)
    target_link_libraries(test_edflib PRIVATE EDFlib)

    add_executable(test_generator test_generator.c)
    target_link_libraries(test_generator PRIVATE EDFlib)

    install(TARGETS sine_generator sweep_generator test_edflib test_generator
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )
endif()
