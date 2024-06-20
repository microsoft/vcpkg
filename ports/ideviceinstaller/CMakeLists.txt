cmake_minimum_required(VERSION 3.15)
project(ideviceinstaller C)

include(GNUInstallDirs)

file(GLOB_RECURSE IDEVICEINSTALLER_SOURCE src/*.c src/*.h)

set(DEFINITIONS)

list(APPEND DEFINITIONS -DPACKAGE_NAME="ideviceinstaller")
list(APPEND DEFINITIONS -DPACKAGE_VERSION="1.1.1")
list(APPEND DEFINITIONS -DPACKAGE_URL="https://github.com/libimobiledevice/ideviceinstaller")
list(APPEND DEFINITIONS -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/ideviceinstaller/issues")

if(UNIX)
    list(APPEND DEFINITIONS -DHAVE_VASPRINTF)
    list(APPEND DEFINITIONS -DHAVE_ASPRINTF)
    list(APPEND DEFINITIONS -DHAVE_UNISTD_H)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND DEFINITIONS -DWIN32)
endif()

find_package(unofficial-libimobiledevice CONFIG REQUIRED)
find_package(libzip CONFIG REQUIRED)
find_path(DIRENT_INCLUDE_DIR dirent.h REQUIRED)

add_executable(ideviceinstaller ${IDEVICEINSTALLER_SOURCE})
target_include_directories(ideviceinstaller PRIVATE
    ${DIRENT_INCLUDE_DIR}
)
target_compile_definitions(ideviceinstaller PRIVATE ${DEFINITIONS})
target_link_libraries(ideviceinstaller PRIVATE
    unofficial::libimobiledevice::libimobiledevice
    libzip::zip
)

if(WIN32)
    find_package(unofficial-getopt-win32 REQUIRED)
    target_link_libraries(ideviceinstaller PRIVATE unofficial::getopt-win32::getopt)
endif()

install(TARGETS ideviceinstaller
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
