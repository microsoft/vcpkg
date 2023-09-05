cmake_minimum_required(VERSION 3.15)
project(idevicerestore C)

include(GNUInstallDirs)

file(GLOB_RECURSE IDEVICERESTORE_SOURCE src/*.c src/*.h)
list(FILTER IDEVICERESTORE_SOURCE EXCLUDE REGEX "sha(1|512)\\.(c|h)$")

set(DEFINITIONS)

list(APPEND DEFINITIONS -DPACKAGE_NAME="idevicerestore")
list(APPEND DEFINITIONS -DPACKAGE_VERSION="1.0.0")
list(APPEND DEFINITIONS -DPACKAGE_URL="https://github.com/libimobiledevice/idevicerestore")
list(APPEND DEFINITIONS -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/idevicerestore/issues")

list(APPEND DEFINITIONS -DHAVE_REVERSE_PROXY)

list(APPEND DEFINITIONS -DHAVE_OPENSSL)

if(UNIX)
    list(APPEND DEFINITIONS -DHAVE_REALPATH)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(CURL CONFIG REQUIRED)
find_package(unofficial-libimobiledevice CONFIG REQUIRED)
find_package(unofficial-libimobiledevice-glue CONFIG REQUIRED)
find_package(unofficial-libirecovery CONFIG REQUIRED)
find_package(libzip CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)
find_path(DIRENT_INCLUDE_DIR dirent.h REQUIRED)

add_executable(idevicerestore ${IDEVICERESTORE_SOURCE})
target_include_directories(idevicerestore PRIVATE
    ${DIRENT_INCLUDE_DIR}
)
target_compile_definitions(idevicerestore PRIVATE ${DEFINITIONS})
target_link_libraries(idevicerestore PRIVATE
    CURL::libcurl
    unofficial::libimobiledevice::libimobiledevice
    unofficial::libimobiledevice-glue::libimobiledevice-glue
    unofficial::libirecovery::libirecovery
    libzip::zip
    OpenSSL::SSL
    OpenSSL::Crypto
    ZLIB::ZLIB
)
if(WIN32)
    find_package(unofficial-getopt-win32 REQUIRED)
    target_link_libraries(idevicerestore PRIVATE unofficial::getopt-win32::getopt)
endif()

install(TARGETS idevicerestore
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
