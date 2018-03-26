# This is a cmake script. Process it with the CMake gui or command line utility
# to produce makefiles / Visual Studio project files on Mac OS X and Windows.
#
# To configure the build options either use the CMake gui, or run the command
# line utility including the "-i" option.

set(CMAKE_LEGACY_CYGWIN_WIN32 0)

project(mosquitto)

cmake_minimum_required(VERSION 2.8)
# Only for version 3 and up. cmake_policy(SET CMP0042 NEW)

set (VERSION 1.4.15)

if (WIN32)
	execute_process(COMMAND cmd /c echo %DATE% %TIME% OUTPUT_VARIABLE TIMESTAMP
			OUTPUT_STRIP_TRAILING_WHITESPACE)
else (WIN32)
	execute_process(COMMAND date "+%F %T%z" OUTPUT_VARIABLE TIMESTAMP
			OUTPUT_STRIP_TRAILING_WHITESPACE)
endif (WIN32)

add_definitions (-DCMAKE -DVERSION=\"${VERSION}\" -DTIMESTAMP=\"${TIMESTAMP}\")

if (WIN32)
	set (BINDIR .)
	set (SBINDIR .)
	set (SYSCONFDIR .)
	set (LIBDIR .)
	set (INCLUDEDIR include)
	set (DATAROOTDIR share)
	set (MANDIR man)
	set (SHAREDEST .)
	add_definitions("-D_CRT_SECURE_NO_WARNINGS")
	add_definitions("-D_CRT_NONSTDC_NO_DEPRECATE")
else (WIN32)
	set (BINDIR bin)
	set (SBINDIR sbin)
	if ("${CMAKE_INSTALL_PREFIX}" STREQUAL /usr)
		set (SYSCONFDIR /etc/mosquitto)
	else ("${CMAKE_INSTALL_PREFIX}" STREQUAL /usr)
		set (SYSCONFDIR etc/mosquitto)
	endif ("${CMAKE_INSTALL_PREFIX}" STREQUAL /usr)
	
	set (LIBDIR lib${LIB_SUFFIX})
	set (CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${LIBDIR}")
	set (INCLUDEDIR include)
	set (DATAROOTDIR share)
	set (MANDIR "${DATAROOTDIR}/man")
	set (SHAREDIR "${DATAROOTDIR}/mosquitto")
endif (WIN32)

option(WITH_TLS
	"Include SSL/TLS support?" ON)
option(WITH_TLS_PSK
	"Include TLS-PSK support (requires WITH_TLS)?" ON)
option(WITH_EC
	"Include Elliptic Curve support (requires WITH_TLS)?" ON)
if (${WITH_TLS} STREQUAL ON)
	find_package(OpenSSL REQUIRED)
	add_definitions("-DWITH_TLS")

	if (${WITH_TLS_PSK} STREQUAL ON)
		add_definitions("-DWITH_TLS_PSK")
	endif (${WITH_TLS_PSK} STREQUAL ON)

	if (${WITH_EC} STREQUAL ON)
		add_definitions("-DWITH_EC")
	endif (${WITH_EC} STREQUAL ON)
else (${WITH_TLS} STREQUAL ON)
	set (OPENSSL_INCLUDE_DIR "")
endif (${WITH_TLS} STREQUAL ON)

option(WITH_SOCKS "Include SOCKS5 support?" ON)
if (${WITH_SOCKS} STREQUAL ON)
	add_definitions("-DWITH_SOCKS")
endif (${WITH_SOCKS} STREQUAL ON)

option(WITH_SRV "Include SRV lookup support?" ON)

# ========================================
# Include projects
# ========================================

add_subdirectory(lib)
add_subdirectory(client)
add_subdirectory(src)
#add_subdirectory(man)

# ========================================
# Install config file
# ========================================

#install(FILES mosquitto.conf aclfile.example pskfile.example pwfile.example DESTINATION "${SYSCONFDIR}")
