set(Header_Files "zip.h" "miniz.h")
source_group("Header Files" FILES "${Header_Files}")

set(Source_Files "zip.c")
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
