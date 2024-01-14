cmake_minimum_required(VERSION 3.7.2)
project (faad VERSION 2.10.1)

option(FAAD_BUILD_BINARIES "Build faad2 binaries" OFF)

file(GLOB_RECURSE FAAD_SOURCES "${CMAKE_CURRENT_LIST_DIR}/libfaad/*.c")
file(GLOB_RECURSE FAAD_HEADERS "${CMAKE_CURRENT_LIST_DIR}/libfaad/*.h")

if (BUILD_SHARED_LIBS)
    list(APPEND FAAD_SOURCES "${CMAKE_CURRENT_LIST_DIR}/project/msvc/libfaad2.def")
endif ()

add_definitions(-DSTDC_HEADERS -DPACKAGE_VERSION=\"${PROJECT_VERSION}\" -D_CRT_SECURE_NO_WARNINGS -DHAVE_LRINTF)
include_directories(
    "${CMAKE_CURRENT_LIST_DIR}/include"
    "${CMAKE_CURRENT_LIST_DIR}/libfaad"
)
add_library(faad ${FAAD_SOURCES} ${FAAD_HEADERS})

if (FAAD_BUILD_BINARIES)
    include_directories(
        "${CMAKE_CURRENT_LIST_DIR}/frontend"
    )
    add_executable(faad_decoder
        "${CMAKE_SOURCE_DIR}/frontend/audio.c"
        "${CMAKE_SOURCE_DIR}/frontend/main.c"
        "${CMAKE_SOURCE_DIR}/frontend/mp4read.c"
        "${CMAKE_SOURCE_DIR}/frontend/unicode_support.c"
    )
    target_link_libraries(faad_decoder PRIVATE faad shell32)
    install(TARGETS faad_decoder DESTINATION "bin")
endif ()

install(
    TARGETS faad
        ARCHIVE DESTINATION "lib"
        LIBRARY DESTINATION "lib"
        RUNTIME DESTINATION "bin"
    )
