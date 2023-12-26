cmake_minimum_required(VERSION 3.19 FATAL_ERROR)
PROJECT(crfsuite)

if(ANDROID AND ANDROID_NATIVE_API_LEVEL LESS 28)
    set(CMAKE_C_STANDARD 99) # no aligned_alloc
endif()

file(GLOB SOURCE_FILE_CQDB
    "lib/cqdb/src/*.c"
)
file(GLOB HEADERS_FILE_CQDB
    "lib/cqdb/include/*.h"
)

file(GLOB SOURCE_FILE_CRF
    "lib/crf/src/*.c"
)
file(GLOB HEADERS_FILE_CRF
    "lib/crf/src/*.h"
)
file(GLOB SOURCE_FILE_FRONTEND
    "frontend/*.c"
)
file(GLOB HEADERS_FILE_FRONTEND
    "frontend/*.h"
)
file(GLOB SOURCE_FILE
    "swig/*.cpp"
    "frontend/*.c"
)
file(GLOB HEADERS_FILE
    "include/*.h"
    "include/*.hpp"
    "frontend/*.h"
)

find_library(LBFGS_LIBRARY lbfgs)

include_directories(lib/cqdb/include/)
include_directories(include/)
include_directories(win32/liblbfgs/)

add_library(cqdb STATIC ${SOURCE_FILE_CQDB} ${HEADERS_FILE_CQDB})
add_library(crf STATIC ${SOURCE_FILE_CRF} ${HEADERS_FILE_CRF})
add_library(crfsuite STATIC ${SOURCE_FILE} ${HEADERS_FILE})

target_link_libraries(crf PUBLIC cqdb ${LBFGS_LIBRARY})
target_link_libraries(crfsuite PUBLIC crf)

install(TARGETS cqdb crf crfsuite
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if (WIN32)
    add_executable(frontend  ${SOURCE_FILE_FRONTEND} ${HEADERS_FILE_FRONTEND})
    target_link_libraries(frontend PUBLIC crf)
    install(TARGETS frontend
        RUNTIME DESTINATION tools
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        )
endif()


install(
    FILES
        ${HEADERS_FILE}
        ${HEADERS_FILE_CQDB}
        ${HEADERS_FILE_CRF}
        ${HEADERS_FILE_FRONTEND}
    DESTINATION
        include/crfsuite
    )
