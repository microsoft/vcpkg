cmake_minimum_required(VERSION 3.20)
project(b64)

set(SOURCE_FILES src/cdecode.c src/cencode.c)
set(HEADER_FILES include/b64/cdecode.h include/b64/cencode.h include/b64/decode.h include/b64/encode.h include/b64/ccommon.h)

add_library(b64 ${SOURCE_FILES} ${HEADER_FILES})
target_compile_definitions(b64 PUBLIC LIBB64_EXPORTS=1)
target_include_directories(b64 PRIVATE include)

set_target_properties(b64 PROPERTIES PUBLIC_HEADER "include/b64/cdecode.h;include/b64/cencode.h;include/b64/decode.h;include/b64/encode.h;include/b64/ccommon.h")

install(TARGETS b64
	EXPORT b64-targets
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include/b64
)

install(EXPORT b64-targets 
	FILE b64-targets.cmake
	DESTINATION lib/cmake/b64)

