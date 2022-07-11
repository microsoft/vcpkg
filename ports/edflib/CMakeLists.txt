cmake_minimum_required(VERSION 3.5)

project(EDFlib VERSION 1.21.0 LANGUAGES C)

option(BUILD_SHARED_LIBS "Build EDFlib as a shared library." OFF)
option(BUILD_TOOLS "Build EDFlib tools." OFF)

include(CTest)
include(GNUInstallDirs)

set(sources edflib.h edflib.c)

if(WIN32 AND BUILD_SHARED_LIBS)
    list(APPEND sources exports.def)
endif()

add_library(EDFlib ${sources})

set_target_properties(EDFlib PROPERTIES PUBLIC_HEADER edflib.h)

install(TARGETS EDFlib
    EXPORT EDFlibTargets
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)
install(FILES $<TARGET_PDB_FILE:EDFlib>
    DESTINATION "${CMAKE_INSTALL_BINDIR}" OPTIONAL
)

install(EXPORT EDFlibTargets
    FILE EDFlibConfig.cmake
    DESTINATION "share/EDFlib"
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

if(BUILD_TESTING)
    add_executable(unittest unittest/unittest.c)
    target_link_libraries(unittest PRIVATE EDFlib)

    add_test(unittest unittest)
endif()
