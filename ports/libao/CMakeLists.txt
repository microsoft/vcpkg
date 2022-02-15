cmake_minimum_required (VERSION 3.8.0)
project (ao C)

include(GNUInstallDirs)
include(CheckLibraryExists)


include_directories(include)

set(CMAKE_DEBUG_POSTFIX d)
add_definitions(-DAO_BUILDING_LIBAO)
add_definitions(-DHAVE_WMM)

file(STRINGS "configure.ac"
    _ao_version_defines REGEX "AC_INIT.*libao\],\[(.*?)\].*$")
foreach(ver ${_ao_version_defines})
    if(ver MATCHES "AC_INIT.*libao\],\[(.*?)\].*$")
        set(VERSION "${CMAKE_MATCH_1}" CACHE INTERNAL "")
    endif()
endforeach()
# include(CheckIncludeFile)
# check_include_file(mmsystem.h HAVE_WMM)
set(SRC
"src/audio_out.c"
"src/config.c"
"src/ao_null.c"
"src/ao_wav.c"
"src/ao_au.c"
"src/ao_raw.c"
"src/ao_aixs.c"
"src/ao_wmm.c"
)

# if(HAVE_WMM)
  # list(APPEND SRC src/ao_wmm.c)
  # target_link_libraries(libao -lwinmm )
# endif()

add_library(ao ${SRC})
target_link_libraries(ao winmm ksuser )
install(
  TARGETS ao
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY include/ DESTINATION include FILES_MATCHING PATTERN "*.h")
endif()

# pkgconfig file
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})

configure_file(ao.pc.in ao.pc @ONLY)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/ao.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
