cmake_minimum_required(VERSION 3.5)
project(libuv C)

file(GLOB UV_SOURCES_COMMON src/*.c)

if (MSVC)
    file(GLOB UV_SOURCES_WIN src/win/*.c)
    add_library(libuv ${UV_SOURCES_COMMON} ${UV_SOURCES_WIN})
    target_compile_definitions(libuv PRIVATE WIN32_LEAN_AND_MEAN "_WIN32_WINNT=0x0600")
    target_link_libraries(libuv iphlpapi psapi shell32 userenv ws2_32)
    target_include_directories(libuv PUBLIC ./include PRIVATE ./src)
    set_target_properties(libuv PROPERTIES DEFINE_SYMBOL BUILDING_UV_SHARED)
elseif (UNIX)
    file(GLOB UV_SOURCES_UNIX
        src/unix/async.c
        src/unix/core.c
        src/unix/dl.c
        src/unix/fs.c
        src/unix/getaddrinfo.c
        src/unix/getnameinfo.c
        src/unix/loop.c
        src/unix/loop-watcher.c
        src/unix/pipe.c
        src/unix/poll.c
        src/unix/process.c
        src/unix/signal.c
        src/unix/stream.c
        src/unix/tcp.c
        src/unix/thread.c
        src/unix/timer.c
        src/unix/tty.c
        src/unix/udp.c
    )
    add_library(libuv ${UV_SOURCES_COMMON} ${UV_SOURCES_UNIX})
    target_include_directories(libuv PUBLIC ./include PRIVATE ./src)
    set_target_properties(libuv PROPERTIES DEFINE_SYMBOL BUILDING_UV_SHARED)
endif()

if(NOT UV_SKIP_HEADERS)
    install(FILES
        include/tree.h
        include/uv.h
        include/uv-version.h
        include/uv-errno.h
        include/uv-threadpool.h
        include/uv-win.h
        include/uv-unix.h
        DESTINATION include)
endif()

install(TARGETS libuv
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)
