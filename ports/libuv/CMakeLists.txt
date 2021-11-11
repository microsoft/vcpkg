cmake_minimum_required(VERSION 3.5)
project(libuv C)

find_package(Threads REQUIRED)

file(GLOB UV_SOURCES_COMMON src/*.c)

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
    src/unix/tty.c
    src/unix/udp.c
)
file(GLOB UV_SOURCES_LINUX
    src/unix/proctitle.c
    src/unix/linux-core.c
    src/unix/linux-inotify.c
    src/unix/linux-syscalls.c
    src/unix/procfs-exepath.c
    src/unix/sysinfo-loadavg.c
    src/unix/sysinfo-memory.c
    src/unix/epoll.c
)
file(GLOB UV_SOURCES_DARWIN
    src/unix/proctitle.c
    src/unix/darwin.c
    src/unix/fsevents.c
    src/unix/darwin-proctitle.c
    src/unix/bsd-ifaddrs.c
    src/unix/kqueue.c
)
file(GLOB UV_SOURCES_FREEBSD
    src/unix/freebsd.c
    src/unix/posix-hrtime.c
    src/unix/bsd-proctitle.c
    src/unix/bsd-ifaddrs.c
    src/unix/kqueue.c
)
file(GLOB UV_SOURCES_WIN src/win/*.c)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    add_library(libuv ${UV_SOURCES_COMMON} ${UV_SOURCES_WIN})
    target_compile_definitions(libuv PRIVATE WIN32_LEAN_AND_MEAN "_WIN32_WINNT=0x0600")
    target_link_libraries(libuv PRIVATE iphlpapi psapi shell32 userenv ws2_32)
elseif(APPLE)
    add_library(libuv ${UV_SOURCES_COMMON} ${UV_SOURCES_UNIX} ${UV_SOURCES_DARWIN})
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    add_library(libuv ${UV_SOURCES_COMMON} ${UV_SOURCES_UNIX} ${UV_SOURCES_FREEBSD})
else() # Assume some Linux variant
    add_library(libuv ${UV_SOURCES_COMMON} ${UV_SOURCES_UNIX} ${UV_SOURCES_LINUX})
endif()

target_link_libraries(libuv PRIVATE Threads::Threads)
target_include_directories(libuv PUBLIC $<INSTALL_INTERFACE:include> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)
set_target_properties(libuv PROPERTIES DEFINE_SYMBOL BUILDING_UV_SHARED)

if(NOT UV_SKIP_HEADERS)
    install(
        DIRECTORY include/
        DESTINATION include
    )
endif()

install(TARGETS libuv
    EXPORT libuv
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(EXPORT libuv FILE unofficial-libuv-targets.cmake NAMESPACE unofficial::libuv:: DESTINATION share/unofficial-libuv)
