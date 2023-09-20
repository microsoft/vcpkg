cmake_minimum_required(VERSION 3.15)
project(libideviceactivation C)

include(GNUInstallDirs)

file(GLOB_RECURSE LIBIDEVICEACTIVATION_HEADER include/*.h)
file(GLOB_RECURSE LIBIDEVICEACTIVATION_SOURCE src/*.c)

set(DEFINITIONS)

if(BUILD_SHARED_LIBS)
    if(WIN32)
        list(APPEND LIBIDEVICEACTIVATION_SOURCE exports.def)
    endif()
else()
    list(APPEND DEFINITIONS -DLIBIDEVICEACTIVATION_STATIC)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libplist CONFIG REQUIRED)
find_package(unofficial-libimobiledevice CONFIG REQUIRED)
find_package(CURL CONFIG REQUIRED)
find_package(LibXml2 CONFIG REQUIRED)

add_library(libideviceactivation ${LIBIDEVICEACTIVATION_SOURCE})
target_include_directories(libideviceactivation
    PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    PUBLIC
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(libideviceactivation PRIVATE ${DEFINITIONS})
target_link_libraries(libideviceactivation
    PRIVATE
        CURL::libcurl
        LibXml2::LibXml2
    PUBLIC
        unofficial::libplist::libplist
        unofficial::libimobiledevice::libimobiledevice
)
set_target_properties(libideviceactivation PROPERTIES OUTPUT_NAME ideviceactivation-1.0)

install(TARGETS libideviceactivation EXPORT unofficial-libideviceactivation)

install(
    EXPORT unofficial-libideviceactivation
    FILE unofficial-libideviceactivation-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-libideviceactivation"
    NAMESPACE unofficial::libideviceactivation::
)

install(
    FILES ${LIBIDEVICEACTIVATION_HEADER}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

set(LIBPLIST_VERSION 2.0)
set(LIBIMOBILEDEVICE_VERSION 1.0)
set(LIBCURL_VERSION 7.0)
set(LIBXML2_VERSION 2.0)
set(PACKAGE_NAME libideviceactivation)
set(PACKAGE_VERSION 1.0)
set(prefix "")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libideviceactivation-1.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libideviceactivation-1.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libideviceactivation-1.0.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
