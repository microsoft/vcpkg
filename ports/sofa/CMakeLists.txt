cmake_minimum_required(VERSION 3.15)

# Sets the name of the <PROJECT-NAME>
project(sofa LANGUAGES C)

include(GNUInstallDirs)

# set SOURCE dir
set(SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

# set .c files except for test_sofa.c
file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.c")
list(REMOVE_ITEM SOURCES "${SOURCE_DIR}/test_sofa.c")

# set .h files
file(GLOB_RECURSE HEADERS "${SOURCE_DIR}/*.h")

# Add a library target called <name>, eg. <name>.lib
add_library(sofa ${SOURCES})

# Sets properties on <targets>
if(BUILD_SHARED_LIBS AND WIN32)
        set_target_properties(sofa PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
elseif(LINUX)
        target_link_libraries(sofa PRIVATE m)
endif()

# Specifies include directories to use when compiling a given <target>
target_include_directories(sofa PUBLIC
        $<BUILD_INTERFACE:${SOURCE_DIR}> # for headers when building
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}> # for client in install mode
)

# Install target <target> <export-name> Output Artifacts and associated files
install(TARGETS sofa
        EXPORT sofa_targets
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

install(FILES ${HEADERS} DESTINATION include)

# Install <export-name> for dependent projects:
install(EXPORT sofa_targets
        FILE unofficial-sofa-targets.cmake
        NAMESPACE unofficial::sofa::
        DESTINATION share/unofficial-sofa)

# Generate the config file in the current binary dir (this ensures it's not placed directly in source)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-sofa-config.cmake"
        "include(CMakeFindDependencyMacro)\n"
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/unofficial-sofa-targets.cmake\")\n"
)

# Install the generated config file
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-sofa-config.cmake"
        DESTINATION share/unofficial-sofa)
