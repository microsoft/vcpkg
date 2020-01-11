cmake_minimum_required(VERSION 3.0.2)

project(enet)

# The "configure" step.
include(CheckFunctionExists)
include(CheckStructHasMember)
include(CheckTypeSize)

check_function_exists("fcntl" HAS_FCNTL)
check_function_exists("poll" HAS_POLL)
check_function_exists("getaddrinfo" HAS_GETADDRINFO)
check_function_exists("getnameinfo" HAS_GETNAMEINFO)
check_function_exists("gethostbyname_r" HAS_GETHOSTBYNAME_R)
check_function_exists("gethostbyaddr_r" HAS_GETHOSTBYADDR_R)
check_function_exists("inet_pton" HAS_INET_PTON)
check_function_exists("inet_ntop" HAS_INET_NTOP)
check_struct_has_member("struct msghdr" "msg_flags" "sys/types.h;sys/socket.h" HAS_MSGHDR_FLAGS)
set(CMAKE_EXTRA_INCLUDE_FILES "sys/types.h" "sys/socket.h")
check_type_size("socklen_t" HAS_SOCKLEN_T BUILTIN_TYPES_ONLY)
unset(CMAKE_EXTRA_INCLUDE_FILES)

add_library(enet STATIC
    callbacks.c
    compress.c
    host.c
    list.c
    packet.c
    peer.c
    protocol.c
    unix.c
    win32.c)

if(MSVC)
    target_compile_options(enet PRIVATE -W3)
else()
    target_compile_options(enet PRIVATE -Wno-error)
endif()
 
if(HAS_FCNTL)
    target_compile_definitions(enet PRIVATE -DHAS_FCNTL=1)
endif()

if(HAS_POLL)
    target_compile_definitions(enet PRIVATE -DHAS_POLL=1)
endif()

if(HAS_GETNAMEINFO)
    target_compile_definitions(enet PRIVATE -DHAS_GETNAMEINFO=1)
endif()

if(HAS_GETADDRINFO)
    target_compile_definitions(enet PRIVATE -DHAS_GETADDRINFO=1)
endif()

if(HAS_GETHOSTBYNAME_R)
    target_compile_definitions(enet PRIVATE -DHAS_GETHOSTBYNAME_R=1)
endif()

if(HAS_GETHOSTBYADDR_R)
    target_compile_definitions(enet PRIVATE -DHAS_GETHOSTBYADDR_R=1)
endif()

if(HAS_INET_PTON)
    target_compile_definitions(enet PRIVATE -DHAS_INET_PTON=1)
endif()

if(HAS_INET_NTOP)
    target_compile_definitions(enet PRIVATE -DHAS_INET_NTOP=1)
endif()

if(HAS_MSGHDR_FLAGS)
    target_compile_definitions(enet PRIVATE -DHAS_MSGHDR_FLAGS=1)
endif()

if(HAS_SOCKLEN_T)
    target_compile_definitions(enet PRIVATE -DHAS_SOCKLEN_T=1)
endif()

target_include_directories(enet PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if (WIN32)
    target_link_libraries(enet PRIVATE winmm ws2_32)
endif()

install(TARGETS enet
    EXPORT enet
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin)

install(EXPORT enet
    FILE enet-targets.cmake
    DESTINATION share/enet/
)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/enet-config.cmake
"include(\${CMAKE_CURRENT_LIST_DIR}/enet-targets.cmake)"
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/enet-config.cmake DESTINATION share/enet)

install(DIRECTORY include/ DESTINATION include)