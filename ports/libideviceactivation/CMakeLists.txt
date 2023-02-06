cmake_minimum_required(VERSION 3.0)
project(libideviceactivation C)

include(GNUInstallDirs)

# find dependencies
find_package(libplist CONFIG REQUIRED)
find_package(libimobiledevice-glue CONFIG REQUIRED)
find_package(libusbmuxd CONFIG REQUIRED)
find_package(libimobiledevice CONFIG REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(CURL REQUIRED)

file(GLOB_RECURSE IDVCACTV_PUBLIC_HDR include/*.h)
file(GLOB_RECURSE IDVCACTV_SRC src/*.c)

add_library(libideviceactivation ${IDVCACTV_SRC} ${IDVCACTV_PUBLIC_HDR})
add_library(unofficial::libideviceactivation::ideviceactivation ALIAS libideviceactivation)
target_include_directories(libideviceactivation PRIVATE ${LIBXML2_INCLUDE_DIR} ${CURL_INCLUDE_DIRS} include)
target_compile_definitions(libideviceactivation PRIVATE -DHAVE_OPENSSL)
target_link_libraries(
    libideviceactivation PRIVATE 
    unofficial::libplist::plist
    unofficial::libimobiledevice-glue::imobiledevice-glue
    unofficial::libusbmuxd::usbmuxd
    unofficial::libimobiledevice::imobiledevice
    ${CURL_LIBRARIES}
    ${LIBXML2_LIBRARIES}
)

add_executable(ideviceactivation tools/ideviceactivation.c)
target_compile_definitions(
    ideviceactivation PRIVATE
    -DPACKAGE_VERSION="1.1.1"
    -DPACKAGE_URL="https://github.com/libimobiledevice/libideviceactivation"
    -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/libideviceactivation/issues"
)
target_include_directories(ideviceactivation PRIVATE include)
target_link_libraries(
    ideviceactivation PRIVATE
    unofficial::libplist::plist
    unofficial::libimobiledevice-glue::imobiledevice-glue
    unofficial::libusbmuxd::usbmuxd
    unofficial::libimobiledevice::imobiledevice
    ${CURL_LIBRARIES}
    ${LIBXML2_LIBRARIES}
    libideviceactivation
)

install(TARGETS ideviceactivation)

target_include_directories(libideviceactivation INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
install(TARGETS libideviceactivation EXPORT libideviceactivation)
install(EXPORT libideviceactivation FILE libideviceactivation-config.cmake DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/libideviceactivation" NAMESPACE unofficial::libideviceactivation::)

set(LIBPLIST_VERSION 2.0)
set(LIMD_GLUE_VERSION 1.0)
set(LIBUSBMUXD_VERSION 2.0)
set(LIBIMOBILEDEVICE_VERSION 1.0)
set(LIBCURL_VERSION 7.0)
set(LIBXML2_VERSION 2.0)
set(PACKAGE_NAME libideviceactivation)
set(PACKAGE_VERSION 1.0)
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "${prefix}")
set(libdir "${prefix}/lib")
set(includedir "${prefix}/include")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libideviceactivation-1.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libideviceactivation-1.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libideviceactivation-1.0.pc"
    DESTINATION lib/pkgconfig
)

install(FILES ${IDVCACTV_PUBLIC_HDR} DESTINATION include)