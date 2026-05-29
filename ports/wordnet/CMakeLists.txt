cmake_minimum_required (VERSION 3.14)
project ("wordnet")
set (target_name ${CMAKE_PROJECT_NAME}) # CMAKE_PROJECT_NAME for the top-level project() call

option (BUILD_SHARED_LIBS "Create ${target_name} as a shared library" OFF)
set (CMAKE_DEBUG_POSTFIX "d" CACHE STRING "postfix for debug lib")

set (INCLUDE_DIR_BUILD "${CMAKE_CURRENT_LIST_DIR}/include")

include (GNUInstallDirs)

file (GLOB wordnet_headers ${INCLUDE_DIR_BUILD}/wn.h)
file (GLOB wordnet_srcs "lib/*.c")

add_library (${target_name} ${wordnet_srcs} ${wordnet_headers})

target_include_directories (${target_name} 
    PRIVATE ${INCLUDE_DIR_BUILD} 
    PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(${target_name} PROPERTIES
    C_STANDARD 11
)

target_compile_definitions(${PROJECT_NAME} PUBLIC DEFAULTPATH="${WORDNET_DICT_PATH}")

if (MSVC)
    set_target_properties(${target_name} PROPERTIES
        VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:${target_name}>
        COMPILE_FLAGS "/wd4996 /wd4267 /wd4244 /wd4047"
    )
    target_compile_definitions(${PROJECT_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${target_name})
endif()

install (TARGETS ${target_name} EXPORT ${target_name}-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES 
    ${wordnet_headers} 
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${target_name}
    CONFIGURATIONS Release
)

install (EXPORT ${target_name}-targets
    FILE ${target_name}-targets.cmake
    NAMESPACE ${target_name}::
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${target_name}"
)

configure_file(${target_name}-config.cmake.in "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target_name}-config.cmake" @ONLY)

install(FILES
  "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target_name}-config.cmake"
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${target_name}"
)

install(DIRECTORY
    dict/ DESTINATION ${WORDNET_DICT_PATH}
    CONFIGURATIONS Release
)
install(DIRECTORY
    doc/ DESTINATION ${CMAKE_INSTALL_DOCDIR}
    CONFIGURATIONS Release
)
