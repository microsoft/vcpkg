cmake_minimum_required(VERSION 3.8)
project(imobiledevice-glue C)

include(GNUInstallDirs)

find_package(libplist CONFIG REQUIRED)

file(GLOB_RECURSE IMDG_HEADERS include/libimobiledevice-glue/*.h)
file(GLOB_RECURSE IMDG_SOURCES SRC/*.c)

add_library(imobiledevice-glue ${IMDG_SOURCES} ${IMDG_HEADERS} include/endianness.h)
add_library(unofficial::libimobiledevice-glue::imobiledevice-glue ALIAS imobiledevice-glue)
set_target_properties(imobiledevice-glue PROPERTIES OUTPUT_NAME imobiledevice-glue-1.0)
target_include_directories(imobiledevice-glue PRIVATE include)
target_link_libraries(imobiledevice-glue PUBLIC unofficial::libplist::plist)
target_compile_definitions(imobiledevice-glue PRIVATE -DHAVE_GETIFADDRS)

target_include_directories(imobiledevice-glue INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
install(TARGETS imobiledevice-glue EXPORT libimobiledevice-glue)
install(EXPORT libimobiledevice-glue FILE libimobiledevice-glue-config.cmake DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/libimobiledevice-glue" NAMESPACE unofficial::libimobiledevice-glue::)

set(LIBPLIST_VERSION 2.0)
set(PACKAGE_NAME libimobiledevice-glue)
set(PACKAGE_VERSION 1.0)
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "${prefix}")
set(libdir "${prefix}/lib")
set(includedir "${prefix}/include")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libimobiledevice-glue-1.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-glue-1.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-glue-1.0.pc"
    DESTINATION lib/pkgconfig)


install(FILES ${IMDG_HEADERS} DESTINATION include/libimobiledevice-glue)
