cmake_minimum_required(VERSION 3.15)
project(libirecovery C)

include(GNUInstallDirs)

file(GLOB_RECURSE LIBIRECOVERY_HEADER include/*.h)
file(GLOB_RECURSE LIBIRECOVERY_SOURCE src/*.c)

set(DEFINITIONS)

if(BUILD_SHARED_LIBS)
    if(WIN32)
        list(APPEND DEFINITIONS -DIRECV_EXPORT)
    endif()
else()
    list(APPEND DEFINITIONS -DIRECV_STATIC)
endif()

if(APPLE)
    list(APPEND DEFINITIONS -DHAVE_IOKIT)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libimobiledevice-glue CONFIG REQUIRED)

add_library(libirecovery ${LIBIRECOVERY_SOURCE})
target_include_directories(libirecovery
    PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    PUBLIC
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(libirecovery PRIVATE ${DEFINITIONS})
target_link_libraries(libirecovery
    PRIVATE
        unofficial::libimobiledevice-glue::libimobiledevice-glue
)
if(NOT WIN32 AND NOT APPLE)
    find_package(libusb CONFIG REQUIRED)
    target_include_directories(libirecovery PRIVATE ${LIBUSB_INCLUDE_DIRS})
    target_link_libraries(libirecovery PRIVATE ${LIBUSB_LIBRARIES})
endif()
set_target_properties(libirecovery PROPERTIES OUTPUT_NAME irecovery-1.0)

if(WIN32)
    target_link_libraries(libirecovery PRIVATE Setupapi)
endif()

if(APPLE)
    target_link_libraries(libirecovery PRIVATE "-framework IOKit" "-framework CoreFoundation")
endif()

install(TARGETS libirecovery EXPORT unofficial-libirecovery)

install(
    EXPORT unofficial-libirecovery
    FILE unofficial-libirecovery-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-libirecovery"
    NAMESPACE unofficial::libirecovery::
)

install(
    FILES ${LIBIRECOVERY_HEADER}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

set(LIMD_GLUE_VERSION 1.0)
set(PACKAGE_NAME libirecovery)
set(PACKAGE_VERSION 1.0)
set(prefix "")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libirecovery-1.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libirecovery-1.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libirecovery-1.0.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
