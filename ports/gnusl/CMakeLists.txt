cmake_minimum_required(VERSION 3.8)
project(libgsl C)

option(INSTALL_HEADERS "Install public header files" ON)

# Function to extract parameter from makefile. Space separated values are returned as lists
function(extract_from_makefile PATTERN RETURN FILEPATH)
    file(READ ${FILEPATH} MAKEFILE_CONTENT)
    string(REGEX MATCH "${PATTERN}" CONTENTS "${MAKEFILE_CONTENT}")
    set(CONTENTS ${CMAKE_MATCH_1})
    # Split string into list
    string(REGEX REPLACE "[ \t]+" ";" CONTENTS "${CONTENTS}")
    if("${CONTENTS}" STREQUAL "")
        message(AUTHOR_WARNING "No match for \"${PATTERN}\" found in file ${FILEPATH}")
    endif()
    # Return 
    set(${RETURN} ${CONTENTS} PARENT_SCOPE)
endfunction(extract_from_makefile)

# Function to extract C sources from makefile
function(extract_sources SUBFOLDER ALLSOURCES)
    extract_from_makefile("lib[a-zA-Z1-9_]*_la_SOURCES[ \t]*=[ \t]*([^\n]*)" SOURCEFILES "${SUBFOLDER}/Makefile.am")
    # Add the folder in front of the file names
    string(REGEX REPLACE "([^;]+)" "${SUBFOLDER}/\\1" SOURCEFILES "${SOURCEFILES}")
    # Return 
    set(${ALLSOURCES} ${${ALLSOURCES}} ${SOURCEFILES} PARENT_SCOPE)
endfunction(extract_sources)

set(SOURCES)
extract_from_makefile("SUBDIRS = ([^\n]*)" FOLDERS "./Makefile.am")
extract_sources("." SOURCES)
foreach(DIR IN LISTS FOLDERS)
    extract_sources("${DIR}" SOURCES)
endforeach()

file(READ gsl_types.h GSLTYPES_H)
string(REPLACE "#ifdef WIN32" "#if 1 /*WIN32*/" GSLTYPES_H "${GSLTYPES_H}")
if(BUILD_SHARED_LIBS)
    string(REPLACE "#  ifdef GSL_DLL" "#  if 1 /*GSL_DLL*/" GSLTYPES_H "${GSLTYPES_H}")
endif()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/gsl_types.h "${GSLTYPES_H}")

file(GLOB_RECURSE PUBLIC_HEADERS gsl*.h)
list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/gsl_types.h)

add_library(libgsl ${SOURCES})
set_target_properties(libgsl PROPERTIES DEFINE_SYMBOL DLL_EXPORT WINDOWS_EXPORT_ALL_SYMBOLS ON)

if(INSTALL_HEADERS)
    set_target_properties(libgsl PROPERTIES PUBLIC_HEADER "${PUBLIC_HEADERS}")
endif()
target_include_directories(libgsl PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
# For the build, we need to copy all headers to the gsl directory
file(COPY ${PUBLIC_HEADERS} DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/gsl")

set(TARGET_INSTALL_OPTIONS)
if(INSTALL_HEADERS)
    set(TARGET_INSTALL_OPTIONS PUBLIC_HEADER DESTINATION include/gsl)
endif()

install(TARGETS libgsl
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    ${TARGET_INSTALL_OPTIONS}
)