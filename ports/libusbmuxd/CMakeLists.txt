cmake_minimum_required(VERSION 3.0)
project(usbmuxd C)

include(GNUInstallDirs)

find_package(libplist CONFIG REQUIRED)
find_package(libimobiledevice-glue CONFIG REQUIRED)

file(GLOB_RECURSE IDVCACTV_PUBLIC_HDR include/*.h)
file(GLOB_RECURSE IDVCACTV_SRC src/*.c)

add_library(usbmuxd ${IDVCACTV_SRC} ${IDVCACTV_PUBLIC_HDR})
add_library(unofficial::libusbmuxd::usbmuxd ALIAS usbmuxd)
set_target_properties(usbmuxd PROPERTIES OUTPUT_NAME usbmuxd-2.0)
target_include_directories(usbmuxd PRIVATE include)
target_compile_definitions(usbmuxd PRIVATE -DPACKAGE_STRING="2.0.2")
if (WIN32)
    target_compile_definitions(usbmuxd PRIVATE -DWIN32)
    target_link_libraries(usbmuxd PRIVATE Ws2_32)
endif()
if (UNIX)
    target_compile_definitions(usbmuxd PRIVATE -DHAVE_STPNCPY)
endif()
target_link_libraries(usbmuxd PUBLIC unofficial::libplist::plist unofficial::libimobiledevice-glue::imobiledevice-glue)

add_executable(iproxy tools/iproxy.c)
target_compile_definitions(
    iproxy PRIVATE 
    -DPACKAGE_VERSION="2.0.2"
    -DPACKAGE_URL="https://github.com/libimobiledevice/libusbmuxd"
    -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/libusbmuxd/issues"
)
target_include_directories(iproxy PRIVATE include)
target_link_libraries(iproxy PRIVATE usbmuxd)

add_executable(inetcat tools/inetcat.c)
target_compile_definitions(
    inetcat PRIVATE 
    -DPACKAGE_VERSION="2.0.2"
    -DPACKAGE_URL="https://github.com/libimobiledevice/libusbmuxd"
    -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/libusbmuxd/issues"
)
target_include_directories(inetcat PRIVATE include)
target_link_libraries(inetcat PRIVATE usbmuxd)

target_include_directories(usbmuxd INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
install(TARGETS usbmuxd EXPORT libusbmuxd)
install(EXPORT libusbmuxd FILE libusbmuxd-config.cmake DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/libusbmuxd" NAMESPACE unofficial::libusbmuxd::)

install(TARGETS iproxy inetcat)

set(LIBPLIST_VERSION 2.0)
set(LIMD_GLUE_VERSION 1.0)
set(PACKAGE_NAME libusbmuxd)
set(PACKAGE_VERSION 2.0)
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "${prefix}")
set(libdir "${prefix}/lib")
set(includedir "${prefix}/include")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libusbmuxd-2.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libusbmuxd-2.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libusbmuxd-2.0.pc"
    DESTINATION lib/pkgconfig
)

install(FILES ${IDVCACTV_PUBLIC_HDR} DESTINATION include)
