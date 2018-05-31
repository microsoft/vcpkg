cmake_minimum_required(VERSION 3.8)

project(SOIL C)

option(INSTALL_HEADERS "Install header files" ON)

set(INSTALL_CMAKE_DIR share/soil)

add_library(SOIL STATIC
    src/image_helper.c
    src/stb_image_aug.c
    src/image_DXT.c
    src/SOIL.c)

target_include_directories(SOIL INTERFACE $<INSTALL_INTERFACE:include>)

if(INSTALL_HEADERS)
    install(TARGETS SOIL
        EXPORT SOILTargets
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib)

    install(FILES src/SOIL.h
        DESTINATION include/SOIL/)

    # Prepare and install package files
    set(SOIL_VERSION "2018.7.7")

    export(TARGETS SOIL FILE "${PROJECT_BINARY_DIR}/SOILTargets.cmake")

    export(PACKAGE SOIL)

    # Create the SOILConfig.cmake and SOILConfigVersion files
    configure_file(SOILConfig.cmake.in        "${PROJECT_BINARY_DIR}/SOILConfig.cmake"        @ONLY)
    configure_file(SOILConfigVersion.cmake.in "${PROJECT_BINARY_DIR}/SOILConfigVersion.cmake" @ONLY)

    # Install the SOILConfig.cmake and SOILConfigVersion.cmake
    install(FILES
        "${PROJECT_BINARY_DIR}/SOILConfig.cmake"
        "${PROJECT_BINARY_DIR}/SOILConfigVersion.cmake"
        DESTINATION "${INSTALL_CMAKE_DIR}")

    # Install the export set for use with the install-tree
    install(EXPORT SOILTargets DESTINATION
        "${INSTALL_CMAKE_DIR}")
else()
    install(TARGETS SOIL
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib)
endif()
