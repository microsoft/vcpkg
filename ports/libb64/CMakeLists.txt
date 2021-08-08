cmake_minimum_required(VERSION 3.20)
project(libb64)

set(SOURCE_FILES src/cdecode.c src/cencode.c)
set(HEADER_FILES include/b64/cdecode.h include/b64/cencode.h)

add_library(b64 STATIC ${SOURCE_FILES} ${HEADER_FILES})
target_include_directories(b64 PRIVATE include)

set_target_properties(b64 PROPERTIES PUBLIC_HEADER "include/b64/cdecode.h;include/b64/cencode.h;include/b64/decode.h;include/b64/encode.h")

install(TARGETS b64
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include/b64
)


