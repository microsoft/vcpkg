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
if(MSVC)
	add_definitions(-W3)
else()
	add_definitions(-Wno-error)
endif()
 
if(HAS_FCNTL)
    add_definitions(-DHAS_FCNTL=1)
endif()
if(HAS_POLL)
    add_definitions(-DHAS_POLL=1)
endif()
if(HAS_GETNAMEINFO)
    add_definitions(-DHAS_GETNAMEINFO=1)
endif()
if(HAS_GETADDRINFO)
    add_definitions(-DHAS_GETADDRINFO=1)
endif()
if(HAS_GETHOSTBYNAME_R)
    add_definitions(-DHAS_GETHOSTBYNAME_R=1)
endif()
if(HAS_GETHOSTBYADDR_R)
    add_definitions(-DHAS_GETHOSTBYADDR_R=1)
endif()
if(HAS_INET_PTON)
    add_definitions(-DHAS_INET_PTON=1)
endif()
if(HAS_INET_NTOP)
    add_definitions(-DHAS_INET_NTOP=1)
endif()
if(HAS_MSGHDR_FLAGS)
    add_definitions(-DHAS_MSGHDR_FLAGS=1)
endif()
if(HAS_SOCKLEN_T)
    add_definitions(-DHAS_SOCKLEN_T=1)
endif()
 
add_library(enet
        callbacks.c
        compress.c
        host.c
        list.c
        packet.c
        peer.c
        protocol.c
        unix.c
        win32.c
    )

add_library(enet::enet ALIAS enet)

target_include_directories(enet PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if (BUILD_SHARED_LIBS)
    target_compile_definitions(enet
        PUBLIC ENET_DLL
        PRIVATE ENET_BUILDING_LIB
    )
endif()
	

if (WIN32)
    target_link_libraries(enet winmm ws2_32)
endif()

set(ENET_CMAKE_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/enet)

configure_file ("${CMAKE_SOURCE_DIR}/libenet.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/libenet.pc" @ONLY)
install (FILES "${CMAKE_CURRENT_BINARY_DIR}/libenet.pc" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")

install(TARGETS enet EXPORT unofficial-enet-config
                     ARCHIVE DESTINATION lib
                     LIBRARY DESTINATION lib
                     RUNTIME DESTINATION bin)

INSTALL(EXPORT unofficial-enet-config
    NAMESPACE unofficial::enet::
    FILE unofficial-enet-config.cmake
    DESTINATION share/unofficial-enet
)

install(DIRECTORY include/
        DESTINATION include)