cmake_minimum_required(VERSION 3.15)
project(libimobiledevice-glue C CXX)

include(GNUInstallDirs)

file(GLOB_RECURSE LIBIMOBILEDEVICEGLUE_SOURCE src/*.c)

set(DEFINITIONS)

if(BUILD_SHARED_LIBS)
    if(WIN32)
        list(APPEND LIBIMOBILEDEVICEGLUE_SOURCE exports.def)
    endif()
else()
    list(APPEND DEFINITIONS -DLIBIMOBILEDEVICEGLUE_STATIC)
endif()

if(UNIX)
    list(APPEND DEFINITIONS -DHAVE_GETIFADDRS)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libplist CONFIG REQUIRED)

add_library(libimobiledevice-glue ${LIBIMOBILEDEVICEGLUE_SOURCE})
target_include_directories(libimobiledevice-glue
    PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    PUBLIC
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(libimobiledevice-glue PRIVATE ${DEFINITIONS})
target_link_libraries(libimobiledevice-glue 
    PUBLIC
        unofficial::libplist::libplist
)
set_target_properties(libimobiledevice-glue PROPERTIES OUTPUT_NAME imobiledevice-glue-1.0)

if(WIN32)
    target_link_libraries(libimobiledevice-glue PRIVATE Ws2_32 Iphlpapi)
endif()

install(TARGETS libimobiledevice-glue EXPORT unofficial-libimobiledevice-glue)

install(
    EXPORT unofficial-libimobiledevice-glue
    FILE unofficial-libimobiledevice-glue-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-libimobiledevice-glue"
    NAMESPACE unofficial::libimobiledevice-glue::
)

install(
    DIRECTORY "${CMAKE_SOURCE_DIR}/include/libimobiledevice-glue"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

set(LIBPLIST_VERSION 2.0)
set(PACKAGE_NAME libimobiledevice-glue)
set(PACKAGE_VERSION 1.0)
set(prefix "")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libimobiledevice-glue-1.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-glue-1.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-glue-1.0.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
