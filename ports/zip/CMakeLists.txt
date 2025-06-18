cmake_minimum_required(VERSION 3.19)
project(zip VERSION "2025.06.13" LANGUAGES C)

set(HOMEPAGE_URL "https://github.com/kuba--/${PROJECT_NAME}")
set(DESCRIPTION "A portable, simple zip library written in C")

set(CMAKE_C_STANDARD 90)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")

set(Header_Files "src/zip.h" "src/miniz.h")
source_group("Header Files" FILES "${Header_Files}")

set(Source_Files "src/zip.c")
source_group("Source Files" FILES "${Source_Files}")

add_library("${PROJECT_NAME}" "${Header_Files}" "${Source_Files}")

include(GNUInstallDirs)
target_include_directories(
        "${PROJECT_NAME}"
        PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

# find_package(miniz CONFIG REQUIRED)
# target_link_libraries("${PROJECT_NAME}" PRIVATE miniz::miniz)

set_target_properties("${PROJECT_NAME}" PROPERTIES LINKER_LANGUAGE C)

#######################################
# Export / installation configuration #
#######################################

set_property(TARGET "${PROJECT_NAME}" PROPERTY VERSION "${${PROJECT_NAME}_VERSION}")
set_property(TARGET "${PROJECT_NAME}" PROPERTY SOVERSION "${${PROJECT_NAME}_VERSION_MAJOR}")

install(TARGETS ${LIBRARY_NAME}
        EXPORT "${PROJECT_NAME}Targets"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

install(FILES ${Header_Files}
        TYPE "INCLUDE")
