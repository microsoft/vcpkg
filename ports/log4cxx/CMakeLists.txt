cmake_minimum_required(VERSION 2.8.9)
project (log4cxx)

find_path(APR_INCLUDE_DIR
  NAMES apr.h
)
if(APR_INCLUDE_DIR-NOTFOUND)
    message(FATAL_ERROR "Cannot locate apr.h")
endif()

find_library(APR_LIBRARIES
  NAMES libapr-1
)
if(APR_LIBRARIES-NOTFOUND)
    message(FATAL_ERROR "Cannot locate the library of `libapr-1`")
endif()

find_path(APRUTIL_INCLUDE_DIR
  NAMES apu.h
)
if(APRUTIL_INCLUDE_DIR-NOTFOUND)
    message(FATAL_ERROR "Cannot locate apu.h")
endif()

find_library(APRUTIL_LIBRARIES
  NAMES libaprutil-1
)
if(APRUTIL_LIBRARIES-NOTFOUND)
    message(FATAL_ERROR "Cannot locate the library of `libaprutil-1`")
endif()

add_compile_options(
    /wd4101
    /wd4275
    /wd4251
    /wd4250
)

configure_file(src/main/include/log4cxx/log4cxx.hw
              ${PROJECT_BINARY_DIR}/include/log4cxx/log4cxx.h COPYONLY)

configure_file(src/main/include/log4cxx/private/log4cxx_private.hw
              ${PROJECT_BINARY_DIR}/include/log4cxx/private/log4cxx_private.h COPYONLY)

set(LOG4CXX_INCLUDE_DIRECTORIES
  ${PROJECT_BINARY_DIR}/include
  src/main/include
  ${APR_INCLUDE_DIR}
  ${APRUTIL_INCLUDE_DIR}
  )

file(GLOB_RECURSE LOG4CXX_SRC
  "${PROJECT_SOURCE_DIR}/src/main/cpp/*.cpp"
)

add_library(log4cxx SHARED ${LOG4CXX_SRC})
target_include_directories(log4cxx PUBLIC ${LOG4CXX_INCLUDE_DIRECTORIES})
SET_TARGET_PROPERTIES(log4cxx PROPERTIES COMPILE_DEFINITIONS "_USRDLL;DLL_EXPORTS;LOG4CXX;WIN32")

target_link_libraries(log4cxx
  ${APRUTIL_LIBRARIES}
  ${APR_LIBRARIES}
  odbc32
  )

install(TARGETS log4cxx
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        )

INSTALL(DIRECTORY src/main/include/ DESTINATION include
    FILES_MATCHING PATTERN "*.h")
INSTALL(DIRECTORY ${PROJECT_BINARY_DIR}/include/ DESTINATION include
    FILES_MATCHING PATTERN "*.h")
