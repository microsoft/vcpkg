cmake_minimum_required(VERSION 3.10)

project(librtmp C)

find_package(ZLIB REQUIRED)
find_package(OpenSSL REQUIRED)

include_directories(${ZLIB_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(CMAKE_DEBUG_POSTFIX "d")

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
    add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS)
endif()

add_definitions(-DLIBRTMP_ONLY)

# List the header files
set(HEADERS librtmp/amf.h
            librtmp/bytes.h
            librtmp/dh.h
            librtmp/dhgroups.h
            librtmp/handshake.h
            librtmp/http.h
            librtmp/log.h
            librtmp/rtmp.h
            librtmp/rtmp_sys.h
)

# List the source files
set(SRCS librtmp/amf.c
         librtmp/hashswf.c
         librtmp/log.c
         librtmp/parseurl.c
         librtmp/rtmp.c
)

if(MSVC)
    set(SRCS_MSVC "librtmp/librtmp.def")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4996")
endif()

add_library(rtmp ${SRCS} ${HEADERS} ${SRCS_MSVC})

target_include_directories(rtmp PRIVATE ./librtmp)
target_link_libraries(rtmp PRIVATE ${ZLIB_LIBRARIES} ${OPENSSL_LIBRARIES})
if(MSVC OR MINGW)
    target_link_libraries(rtmp PRIVATE Ws2_32.lib Winmm.lib)
endif()

set(libdir [[${prefix}/lib]])
set(VERSION 2.6) # from ChangeLog
set(CRYPTO_REQ "libssl,libcrypto")
if(MSVC OR MINGW)
    set(PRIVATE_LIBS "-lWS2_32 -lWinMM")
endif()
configure_file(librtmp/librtmp.pc.in librtmp.pc @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/librtmp.pc
        DESTINATION lib/pkgconfig
)

install(TARGETS rtmp
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(DIRECTORY ${PROJECT_SOURCE_DIR}/librtmp DESTINATION include FILES_MATCHING PATTERN "*.h")
