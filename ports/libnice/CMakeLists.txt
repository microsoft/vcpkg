cmake_minimum_required(VERSION 3.0)
project(libnice
	LANGUAGES C
	VERSION 0.1.15)
SET (this_target libnice)

add_definitions(
	-D_CRT_SECURE_NO_WARNINGS
	-D_SCL_SECURE_NO_WARNINGS
	-DHAVE_OPENSSL
	-DPACKAGE_STRING="${PROJECT_VERSION}")

configure_file(${CMAKE_SOURCE_DIR}/win32/vs9/config.h ${CMAKE_SOURCE_DIR}/config.h COPYONLY)
configure_file(${CMAKE_SOURCE_DIR}/win32/vs9/libnice.def ${CMAKE_SOURCE_DIR}/libnice.def COPYONLY)

find_path(GLIB_INCLUDE_DIR glib.h)
find_library(GLIB_LIBRARY glib-2.0)
find_library(GOBJECT_LIBRARY gobject-2.0)
find_library(GIO_LIBRARY gio-2.0)
find_library(IPHLPAPI_LIBRARY iphlpapi)
find_library(WS2_32_LIB ws2_32)
find_package(OpenSSL REQUIRED)
include_directories(
	${CMAKE_CURRENT_SOURCE_DIR} 
	${CMAKE_CURRENT_SOURCE_DIR}/agent
	${CMAKE_CURRENT_SOURCE_DIR}/random 
	${CMAKE_CURRENT_SOURCE_DIR}/socket
	${CMAKE_CURRENT_SOURCE_DIR}/stun
	${GLIB_INCLUDE_DIR})


SET (SRCS
	./agent/address.c
	./agent/agent-enum-types.c
	./agent/agent.c
	./agent/candidate.c
	./agent/component.c
	./agent/conncheck.c
	./agent/debug.c
	./agent/discovery.c
	./agent/inputstream.c
	./agent/interfaces.c
	./agent/iostream.c
	./agent/outputstream.c
	./agent/pseudotcp.c
	./agent/stream.c
	./random/random-glib.c
	./random/random.c
	./random/test.c
	./socket/http.c
	./socket/pseudossl.c
	./socket/socket.c
	./socket/socks5.c
	./socket/tcp-active.c
	./socket/tcp-bsd.c
	./socket/tcp-passive.c
	./socket/udp-bsd.c
	./socket/udp-turn-over-tcp.c
	./socket/udp-turn.c
	./stun/debug.c
	./stun/rand.c
	./stun/stun5389.c
	./stun/stunagent.c
	./stun/stuncrc32.c
	./stun/stunhmac.c
	./stun/stunmessage.c
	./stun/usages/bind.c
	./stun/usages/ice.c
	./stun/usages/timer.c
	./stun/usages/turn.c
	./stun/utils.c
	./libnice.def
	)
SET(HEADERS
	./agent/address.h
	./agent/agent-enum-types.h
	./agent/agent-priv.h
	./agent/agent.h
	./agent/candidate.h
	./agent/component.h
	./agent/conncheck.h
	./agent/debug.h
	./agent/discovery.h
	./agent/inputstream.h
	./agent/interfaces.h
	./agent/iostream.h
	./agent/outputstream.h
	./agent/pseudotcp.h
	./agent/stream.h
	./config.h
	./nice/nice.h
	./random/random-glib.h
	./random/random.h
	./socket/http.h
	./socket/pseudossl.h
	./socket/socket-priv.h
	./socket/socket.h
	./socket/socks5.h
	./socket/tcp-active.h
	./socket/tcp-bsd.h
	./socket/tcp-passive.h
	./socket/udp-bsd.h
	./socket/udp-turn-over-tcp.h
	./socket/udp-turn.h
	./stun/constants.h
	./stun/debug.h
	./stun/rand.h
	./stun/stun5389.h
	./stun/stunagent.h
	./stun/stuncrc32.h
	./stun/stunhmac.h
	./stun/stunmessage.h
	./stun/tools/stund.h
	./stun/usages/bind.h
	./stun/usages/ice.h
	./stun/usages/timer.h
	./stun/usages/turn.h
	./stun/utils.h
	./stun/win32_common.h
	./win32/vs9/config.h
	)
add_library(libnice ${SRCS} ${HEADERS})
set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "/wd4244 /wd4005 /wd4391 /wd4142 /wd4267")
target_link_libraries(libnice ${IPHLPAPI_LIBRARY} ${WS2_32_LIB} ${GLIB_LIBRARY} ${GOBJECT_LIBRARY} ${GIO_LIBRARY} OpenSSL::SSL)
install(TARGETS libnice
RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if (CMAKE_BUILD_TYPE STREQUAL "Release")
install(FILES agent/address.h DESTINATION include/nice)
install(FILES agent/agent.h DESTINATION include/nice)
install(FILES agent/candidate.h DESTINATION include/nice)
install(FILES agent/debug.h DESTINATION include/nice)
install(FILES agent/interfaces.h DESTINATION include/nice)
install(FILES nice/nice.h DESTINATION include/nice)
install(FILES agent/pseudotcp.h DESTINATION include/nice)
install(FILES stun/constants.h DESTINATION include/stun)
install(FILES stun/debug.h DESTINATION include/stun)
install(FILES stun/stunagent.h DESTINATION include/stun)
install(FILES stun/stunmessage.h DESTINATION include/stun)
install(FILES stun/usages/bind.h DESTINATION include/stun/usages)
install(FILES stun/usages/ice.h DESTINATION include/stun/usages)
install(FILES stun/usages/timer.h DESTINATION include/stun/usages)
install(FILES stun/usages/turn.h DESTINATION include/stun/usages)
install(FILES stun/win32_common.h DESTINATION include/stun)
endif()