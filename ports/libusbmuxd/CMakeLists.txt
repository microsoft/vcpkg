cmake_minimum_required(VERSION 3.15)
project(libusbmuxd C)

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
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libplist CONFIG REQUIRED)
find_package(unofficial-libimobiledevice-glue CONFIG REQUIRED)

add_library(libusbmuxd ${LIBUSBMUXD_SOURCE})
target_include_directories(libusbmuxd
    PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    PUBLIC
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
