cmake_minimum_required(VERSION 3.20)
project(b64)

set(SOURCE_FILES src/cdecode.c src/cencode.c)
set(HEADER_FILES include/b64/cdecode.h include/b64/cencode.h include/b64/decode.h include/b64/encode.h)

add_compile_definitions(-DLIBB64_EXPORTS)
add_library(b64 ${SOURCE_FILES} ${HEADER_FILES})
target_include_directories(b64 PRIVATE include)

set_target_properties(b64 PROPERTIES PUBLIC_HEADER "include/b64/cdecode.h;include/b64/cencode.h;include/b64/decode.h;include/b64/encode.h")

install(TARGETS b64
	EXPORT b64-targets
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include/b64
)

install(EXPORT b64-targets 
	FILE b64-targets.cmake
	DESTINATION lib/cmake/b64)

