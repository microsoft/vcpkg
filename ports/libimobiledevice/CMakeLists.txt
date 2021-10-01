cmake_minimum_required(VERSION 3.0)
project(libimobiledevice C)

# find dependencies
find_library(libplist NAMES plist plist-2.0 libplist libplist-2.0 REQUIRED)
find_library(libusbmuxd libusbmuxd REQUIRED)
find_package(OpenSSL REQUIRED)
find_path(dirent_INCLUDE_DIR dirent.h)
if (WIN32)
    find_library(getopt getopt REQUIRED)
endif()

# ready to create library
file(GLOB_RECURSE IMOBDEV_COMMON_HDR common/*.h)
file(GLOB_RECURSE IMOBDEV_COMMON_SRC common/*.c)

file(GLOB IMOBDEV_PUBLIC_HDR include/*.h)
file(GLOB IMOBDEV_PUBLIC_SUB_HDR include/libimobiledevice/*.h)
file(GLOB_RECURSE IMOBDEV_PRIVATE_HDR src/*.h)
file(GLOB_RECURSE IMOBDEV_SRC src/*.c)

add_library(libimobiledevice ${IMOBDEV_SRC} ${IMOBDEV_PUBLIC_HDR} ${IMOBDEV_PUBLIC_SUB_HDR} ${IMOBDEV_PRIVATE_HDR} ${IMOBDEV_COMMON_HDR} ${IMOBDEV_COMMON_SRC})
set_target_properties(libimobiledevice PROPERTIES OUTPUT_NAME libimobiledevice-1.0)
target_include_directories(libimobiledevice PRIVATE ${dirent_INCLUDE_DIR} include .)
target_compile_definitions(libimobiledevice PRIVATE -DHAVE_OPENSSL)
target_link_libraries(libimobiledevice PRIVATE ${libplist} ${libusbmuxd} ${getopt} OpenSSL::SSL OpenSSL::Crypto)
if (WIN32)
    target_link_libraries(libimobiledevice PRIVATE Ws2_32)
else()
endif()

# install
install(
    TARGETS libimobiledevice
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

set(LIBPLIST_VERSION 2.0)
set(LIBUSBMUXD_VERSION 2.0)
set(PACKAGE_NAME libimobiledevice)
set(PACKAGE_VERSION 1.0)
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix \${prefix})
set(libdir \${prefix}/lib)
set(includedir \${prefix}/../include)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libimobiledevice-1.0.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-1.0.pc
    @ONLY
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/libimobiledevice-1.0.pc
    DESTINATION lib/pkgconfig
)

install(FILES ${IMOBDEV_PUBLIC_HDR} DESTINATION include)
install(FILES ${IMOBDEV_PUBLIC_SUB_HDR} DESTINATION include/libimobiledevice)