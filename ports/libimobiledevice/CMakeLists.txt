cmake_minimum_required(VERSION 3.0)
project(imobiledevice C)

include(GNUInstallDirs)

# find dependencies
find_package(libplist CONFIG REQUIRED)
find_package(libimobiledevice-glue CONFIG REQUIRED)
find_package(libusbmuxd CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
find_path(dirent_INCLUDE_DIR dirent.h REQUIRED)

# ready to create library
file(GLOB_RECURSE IMOBDEV_COMMON_HDR common/*.h)
file(GLOB_RECURSE IMOBDEV_COMMON_SRC common/*.c)

file(GLOB IMOBDEV_PUBLIC_HDR include/*.h)
file(GLOB IMOBDEV_PUBLIC_SUB_HDR include/libimobiledevice/*.h)
file(GLOB_RECURSE IMOBDEV_PRIVATE_HDR src/*.h)
file(GLOB_RECURSE IMOBDEV_SRC src/*.c)

add_library(imobiledevice ${IMOBDEV_SRC} ${IMOBDEV_PUBLIC_HDR} ${IMOBDEV_PUBLIC_SUB_HDR} ${IMOBDEV_PRIVATE_HDR} ${IMOBDEV_COMMON_HDR} ${IMOBDEV_COMMON_SRC})
add_library(unofficial::libimobiledevice::imobiledevice ALIAS imobiledevice)
set_target_properties(imobiledevice PROPERTIES OUTPUT_NAME imobiledevice-1.0)
target_include_directories(imobiledevice PRIVATE ${dirent_INCLUDE_DIR} include .)
target_compile_definitions(imobiledevice PRIVATE -DHAVE_OPENSSL)
target_link_libraries(
    imobiledevice PRIVATE
    unofficial::libplist::plist
    unofficial::libimobiledevice-glue::imobiledevice-glue
    unofficial::libusbmuxd::usbmuxd
    OpenSSL::SSL OpenSSL::Crypto
)
if (WIN32)
    target_link_libraries(imobiledevice PRIVATE Ws2_32)
endif()
if (UNIX)
    target_compile_definitions(imobiledevice PRIVATE -DHAVE_STPCPY -DHAVE_VASPRINTF -DHAVE_ASPRINTF -DHAVE_GETIFADDRS)
endif()

target_include_directories(imobiledevice INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
install(TARGETS imobiledevice EXPORT libimobiledevice)
install(EXPORT libimobiledevice FILE libimobiledevice-config.cmake DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/libimobiledevice" NAMESPACE unofficial::libimobiledevice::)

set(LIBPLIST_VERSION 2.0)
set(LIMD_GLUE_VERSION 1.0)
set(LIBUSBMUXD_VERSION 2.0)
set(PACKAGE_NAME libimobiledevice)
set(PACKAGE_VERSION 1.0)
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "${prefix}")
set(libdir "${prefix}/lib")
set(includedir "${prefix}/include")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/libimobiledevice-1.0.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-1.0.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-1.0.pc"
    DESTINATION lib/pkgconfig
)

install(FILES ${IMOBDEV_PUBLIC_SUB_HDR} DESTINATION include/libimobiledevice)
