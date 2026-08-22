cmake_minimum_required(VERSION 3.15)
project(libimobiledevice C)

option(BUILD_TOOLS "Build tools." OFF)

include(GNUInstallDirs)

file(GLOB_RECURSE LIBIMOBILEDEVICE_SOURCE src/*.c src/*.h)
file(GLOB_RECURSE LIBIMOBILEDEVICE_COMMON_SOURCE common/*.c common/*.h)

set(DEFINITIONS)

list(APPEND DEFINITIONS -DHAVE_OPENSSL)

if(BUILD_SHARED_LIBS)
    if(WIN32)
        list(APPEND LIBIMOBILEDEVICE_SOURCE exports.def)
    endif()
else()
    list(APPEND DEFINITIONS -DLIBIMOBILEDEVICE_STATIC)
endif()

if(UNIX)
    list(APPEND DEFINITIONS -DHAVE_STPCPY)
    list(APPEND DEFINITIONS -DHAVE_VASPRINTF)
    list(APPEND DEFINITIONS -DHAVE_ASPRINTF)
    list(APPEND DEFINITIONS -DHAVE_GETIFADDRS)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32_LEAN_AND_MEAN)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libplist CONFIG REQUIRED)
find_package(unofficial-libimobiledevice-glue CONFIG REQUIRED)
find_package(unofficial-libusbmuxd CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)

add_library(libimobiledevice ${LIBIMOBILEDEVICE_SOURCE} ${LIBIMOBILEDEVICE_COMMON_SOURCE})
target_include_directories(libimobiledevice PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>"
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(libimobiledevice PRIVATE ${DEFINITIONS})
target_link_libraries(libimobiledevice
    PRIVATE
        unofficial::libimobiledevice-glue::libimobiledevice-glue
        unofficial::libusbmuxd::libusbmuxd
        OpenSSL::SSL
        OpenSSL::Crypto
    PUBLIC
        unofficial::libplist::libplist
)
set_target_properties(libimobiledevice PROPERTIES OUTPUT_NAME imobiledevice-1.0)

if(WIN32)
    target_link_libraries(libimobiledevice PRIVATE Ws2_32)
endif()

install(TARGETS libimobiledevice EXPORT unofficial-libimobiledevice)

install(
    EXPORT unofficial-libimobiledevice
    FILE unofficial-libimobiledevice-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-libimobiledevice"
    NAMESPACE unofficial::libimobiledevice::
)

install(
    DIRECTORY "${CMAKE_SOURCE_DIR}/include/libimobiledevice"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

install(
    FILES "${CMAKE_SOURCE_DIR}/include/endianness.h"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

set(LIBPLIST_VERSION 2.0)
set(LIMD_GLUE_VERSION 1.0)
set(LIBUSBMUXD_VERSION 2.0)
set(PACKAGE_NAME libimobiledevice)
set(PACKAGE_VERSION 1.0)
set(prefix "")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libimobiledevice-1.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-1.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-1.0.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)

if(BUILD_TOOLS)
    if(WIN32)
        find_package(unofficial-getopt-win32 REQUIRED)
    endif()

    function(add_tool name source)
        add_executable("${name}" "${source}" ${LIBIMOBILEDEVICE_COMMON_SOURCE})
        target_compile_definitions("${name}" PRIVATE
            -DPACKAGE_VERSION="2.0.2"
            -DPACKAGE_URL="https://github.com/libimobiledevice/libusbmuxd"
            -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/libusbmuxd/issues"
            -DHAVE_OPENSSL
        )
        target_link_libraries("${name}" PRIVATE 
            libimobiledevice
            unofficial::libimobiledevice-glue::libimobiledevice-glue
            unofficial::libusbmuxd::libusbmuxd
            OpenSSL::SSL
            OpenSSL::Crypto
        )
        if(WIN32)
            target_compile_definitions("${name}" PRIVATE
                -D_CRT_SECURE_NO_WARNINGS
                -DWIN32_LEAN_AND_MEAN
                -DWIN32
            )
            target_link_libraries("${name}" PRIVATE unofficial::getopt-win32::getopt Ws2_32)
        endif()
        if(UNIX)
            target_compile_definitions("${name}" PRIVATE
                -DHAVE_VASPRINTF
                -DHAVE_ASPRINTF
            )
        endif()
    endfunction(add_tool)

    add_tool(idevice_id "tools/idevice_id.c")
    add_tool(idevicebackup "tools/idevicebackup.c")
    add_tool(idevicebackup2 "tools/idevicebackup2.c")
    add_tool(idevicebtlogger "tools/idevicebtlogger.c")
    add_tool(idevicecrashreport "tools/idevicecrashreport.c")
    add_tool(idevicedate "tools/idevicedate.c")
    add_tool(idevicedebug "tools/idevicedebug.c")
    add_tool(idevicedebugserverproxy "tools/idevicedebugserverproxy.c")
    add_tool(idevicedevmodectl "tools/idevicedevmodectl.c")
    add_tool(idevicediagnostics "tools/idevicediagnostics.c")
    add_tool(ideviceenterrecovery "tools/ideviceenterrecovery.c")
    add_tool(ideviceimagemounter "tools/ideviceimagemounter.c")
    add_tool(ideviceinfo "tools/ideviceinfo.c")
    add_tool(idevicename "tools/idevicename.c")
    add_tool(idevicenotificationproxy "tools/idevicenotificationproxy.c")
    add_tool(idevicepair "tools/idevicepair.c")
    add_tool(ideviceprovision "tools/ideviceprovision.c")
    add_tool(idevicescreenshot "tools/idevicescreenshot.c")
    add_tool(idevicesetlocation "tools/idevicesetlocation.c")
    add_tool(idevicesyslog "tools/idevicesyslog.c")

    install(
        TARGETS
            idevice_id
            idevicebackup
            idevicebackup2
            idevicebtlogger
            idevicecrashreport
            idevicedate
            idevicedebug
            idevicedebugserverproxy
            idevicedevmodectl
            idevicediagnostics
            ideviceenterrecovery
            ideviceimagemounter
            ideviceinfo
            idevicename
            idevicenotificationproxy
            idevicepair
            ideviceprovision
            idevicescreenshot
            idevicesetlocation
            idevicesyslog
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )
endif()
