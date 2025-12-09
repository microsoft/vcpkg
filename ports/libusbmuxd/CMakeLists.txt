cmake_minimum_required(VERSION 3.15)
project(libusbmuxd C)

option(BUILD_TOOLS "Build tools." OFF)

include(GNUInstallDirs)

file(GLOB_RECURSE LIBUSBMUXD_HEADER include/*.h)
file(GLOB_RECURSE LIBUSBMUXD_SOURCE src/*.c)

set(DEFINITIONS)

list(APPEND DEFINITIONS -DPACKAGE_STRING="2.0.2")

if(BUILD_SHARED_LIBS)
    if(WIN32)
        list(APPEND LIBUSBMUXD_SOURCE exports.def)
    endif()
else()
    list(APPEND DEFINITIONS -DLIBUSBMUXD_STATIC)
endif()

if(UNIX)
    list(APPEND DEFINITIONS -DHAVE_GETIFADDRS)
    list(APPEND DEFINITIONS -DHAVE_STPNCPY)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32_LEAN_AND_MEAN)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libplist CONFIG REQUIRED)
find_package(unofficial-libimobiledevice-glue CONFIG REQUIRED)

add_library(libusbmuxd ${LIBUSBMUXD_SOURCE})
target_include_directories(libusbmuxd PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(libusbmuxd PRIVATE ${DEFINITIONS})
target_link_libraries(libusbmuxd
    PRIVATE
        unofficial::libplist::libplist
        unofficial::libimobiledevice-glue::libimobiledevice-glue
)
set_target_properties(libusbmuxd PROPERTIES OUTPUT_NAME usbmuxd-2.0)

if(WIN32)
    target_link_libraries(libusbmuxd PRIVATE Ws2_32)
endif()

install(TARGETS libusbmuxd EXPORT unofficial-libusbmuxd)

install(
    EXPORT unofficial-libusbmuxd
    FILE unofficial-libusbmuxd-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-libusbmuxd"
    NAMESPACE unofficial::libusbmuxd::
)

install(
    FILES ${LIBUSBMUXD_HEADER}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

set(LIBPLIST_VERSION 2.0)
set(LIMD_GLUE_VERSION 1.0)
set(PACKAGE_NAME libusbmuxd)
set(PACKAGE_VERSION 2.0)
set(prefix "")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libusbmuxd-2.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libusbmuxd-2.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libusbmuxd-2.0.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)

if(BUILD_TOOLS)
    if(WIN32)
        find_package(unofficial-getopt-win32 REQUIRED)
    endif()

    function(add_tool name source)
        add_executable("${name}" "${source}")
        target_compile_definitions("${name}" PRIVATE
            -DPACKAGE_VERSION="2.0.2"
            -DPACKAGE_URL="https://github.com/libimobiledevice/libusbmuxd"
            -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/libusbmuxd/issues"
        )
        target_link_libraries("${name}" PRIVATE libusbmuxd unofficial::libimobiledevice-glue::libimobiledevice-glue)
        if(WIN32)
            target_compile_definitions("${name}" PRIVATE
                -D_CRT_SECURE_NO_WARNINGS
                -DWIN32_LEAN_AND_MEAN
                -DWIN32
            )
            target_link_libraries("${name}" PRIVATE unofficial::getopt-win32::getopt Ws2_32)
        endif()
    endfunction(add_tool)

    add_tool(inetcat "tools/inetcat.c")
    add_tool(iproxy "tools/iproxy.c")

    install(
        TARGETS inetcat iproxy
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )
endif()
