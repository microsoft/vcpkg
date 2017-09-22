cmake_minimum_required(VERSION 3.0)
project(lz4 C)

if(BUILD_SHARED_LIBS)
    add_definitions(-DLZ4_DLL_EXPORT)
endif()
add_definitions(-DXXH_NAMESPACE=LZ4_)

add_library(lz4
    lib/lz4.c
    lib/lz4frame.c
    lib/lz4hc.c
    lib/xxhash.c)

install(TARGETS lz4
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT LZ4_SKIP_INCLUDES)
    install(FILES
        lib/lz4.h
        lib/lz4frame.h
        lib/lz4hc.h
        DESTINATION include)
endif()
