cmake_minimum_required(VERSION 3.15)

# Sets the name of the <PROJECT-NAME>
project(iausofa LANGUAGES C)

include(GNUInstallDirs)

# set SOURCE dir
set(SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

# set .c files except for test_sofa.c
file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.c")
list(REMOVE_ITEM SOURCES "${SOURCE_DIR}/test_sofa.c")

# set .h files
file(GLOB_RECURSE HEADERS "${SOURCE_DIR}/*.h")

# Add a library target called <name>, eg. <name>.lib
add_library(iausofa ${SOURCES})

# Sets properties on <targets>
if(LINUX)
        target_link_libraries(iausofa PRIVATE m)
endif()

# Specifies include directories to use when compiling a given <target>
target_include_directories(iausofa PUBLIC
        $<BUILD_INTERFACE:${SOURCE_DIR}> # for headers when building
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}> # for client in install mode
)

# Install target <target> <export-name> Output Artifacts and associated files
install(TARGETS iausofa
        EXPORT iausofa_targets
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

install(FILES ${HEADERS} DESTINATION include/iausofa)

# Install <export-name> for dependent projects:
install(EXPORT iausofa_targets
        FILE unofficial-iausofa-targets.cmake
        NAMESPACE unofficial::iausofa::
        DESTINATION share/unofficial-iausofa)

# Generate the config file in the current binary dir (this ensures it's not placed directly in source)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-iausofa-config.cmake"
        "include(CMakeFindDependencyMacro)\n"
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/unofficial-iausofa-targets.cmake\")\n"
)

# Install the generated config file
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-iausofa-config.cmake"
        DESTINATION share/unofficial-iausofa)
