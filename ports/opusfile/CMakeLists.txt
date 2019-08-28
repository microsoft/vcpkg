cmake_minimum_required(VERSION 3.4)
project(opusfile C)

if(MSVC)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4267 /wd4244 /wd4090")
endif()

find_path(OGG_INCLUDE_DIR ogg/ogg.h)
find_library(OGG_LIBRARY ogg)

find_path(OPUS_INCLUDE_DIR opus.h PATH_SUFFIXES opus)
find_library(OPUS_LIBRARY opus)

add_library(opusfile
    src/info.c
    src/internal.c
    src/opusfile.c
    src/stream.c)

target_include_directories(opusfile PRIVATE include PUBLIC ${OGG_INCLUDE_DIR} ${OPUS_INCLUDE_DIR})
target_link_libraries(opusfile PRIVATE ${OGG_LIBRARY} ${OPUS_LIBRARY})

install(TARGETS opusfile
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

if(BUILD_OPUSURL)
    find_package(OpenSSL MODULE REQUIRED)

    add_library(opusurl
        src/http.c
        src/wincerts.c)

    target_compile_definitions(opusurl PRIVATE OP_ENABLE_HTTP)
    target_include_directories(opusurl PRIVATE include)
    target_link_libraries(opusurl PRIVATE opusfile OpenSSL::SSL ws2_32.lib crypt32.lib)

    install(TARGETS opusurl
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)
endif()

if(NOT OPUSFILE_SKIP_HEADERS)
    install(FILES include/opusfile.h
        DESTINATION include/opus)
endif()
