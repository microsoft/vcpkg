cmake_minimum_required(VERSION 3.15)
project(usbmuxd C)

include(GNUInstallDirs)

file(GLOB_RECURSE USBMUXD_SOURCE src/*.c src/*.h)

set(DEFINITIONS)

list(APPEND DEFINITIONS -DPACKAGE_NAME="usbmuxd")
list(APPEND DEFINITIONS -DPACKAGE_STRING="1.1.1")
list(APPEND DEFINITIONS -DPACKAGE_VERSION="1.1.1")
list(APPEND DEFINITIONS -DPACKAGE_URL="https://github.com/libimobiledevice/usbmuxd")
list(APPEND DEFINITIONS -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/usbmuxd/issues")

if(UNIX)
    list(APPEND DEFINITIONS -DHAVE_CLOCK_GETTIME)
endif()

if(UNIX AND NOT APPLE)
    list(APPEND DEFINITIONS -DHAVE_PPOLL)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libimobiledevice CONFIG REQUIRED)
find_package(unofficial-libimobiledevice-glue CONFIG REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(libusb REQUIRED IMPORTED_TARGET libusb-1.0)
find_path(DIRENT_INCLUDE_DIR dirent.h REQUIRED)

add_executable(usbmuxd ${USBMUXD_SOURCE})
target_include_directories(usbmuxd PRIVATE
    ${DIRENT_INCLUDE_DIR}
)
target_compile_definitions(usbmuxd PRIVATE ${DEFINITIONS})
target_link_libraries(usbmuxd PRIVATE
    unofficial::libimobiledevice::libimobiledevice
    unofficial::libimobiledevice-glue::libimobiledevice-glue
    PkgConfig::libusb
)
if(WIN32)
    find_package(PThreads4W REQUIRED)
    find_package(unofficial-getopt-win32 REQUIRED)
    target_link_libraries(usbmuxd PRIVATE PThreads4W::PThreads4W unofficial::getopt-win32::getopt)
endif()

install(TARGETS usbmuxd
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
