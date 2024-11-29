cmake_minimum_required(VERSION 3.17)

project(r8brain VERSION 6.5 LANGUAGES CXX C)

option(R8B_INSTALL "Install library" ON)
option(R8B_PFFFT "Use PFFFT" OFF)
option(R8B_PFFFT_DOUBLE "Use PFFFT_DOUBLE" OFF)

if(R8B_INSTALL)
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)
endif()

file(GLOB_RECURSE _src *.h *.cpp *.c)

set(_src
    r8bbase.cpp
)
if(R8B_PFFFT)
    list(APPEND _src pffft.cpp)
endif()
if(R8B_PFFFT_DOUBLE)
    list(APPEND _src pffft_double/pffft_double.c)
endif()

add_library(r8bsrc ${_src})

if(R8B_PFFFT)
    target_compile_definitions(r8bsrc PUBLIC R8B_PFFFT=1)
endif()

if(R8B_PFFFT_DOUBLE)
    target_compile_definitions(r8bsrc PUBLIC R8B_PFFFT_DOUBLE=1)
endif()

if(R8B_INSTALL)
    install(TARGETS r8bsrc
        EXPORT unofficial-${PROJECT_NAME}Targets
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" OPTIONAL
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" OPTIONAL
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" OPTIONAL
    )
    target_include_directories(r8bsrc PUBLIC
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )

    install(EXPORT unofficial-${PROJECT_NAME}Targets
        FILE "unofficial-${PROJECT_NAME}Config.cmake"
        NAMESPACE unofficial::r8brain::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-${PROJECT_NAME}
    )

    file(GLOB _headers *.h *.inc)
    list(FILTER _headers EXCLUDE REGEX r8butil.h)
    if(NOT R8B_PFFFT)
        list(FILTER _headers EXCLUDE REGEX pffft.h)
    endif()
    install(
        FILES ${_headers}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/r8brain
    )
    if(R8B_PFFFT_DOUBLE)
        install(
            FILES pffft_double/pffft_double.h
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/r8brain/pffft_double
        )
    endif()
endif()
