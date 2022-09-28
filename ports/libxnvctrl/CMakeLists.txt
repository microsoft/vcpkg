cmake_minimum_required(VERSION 3.24)
project(XNVCtrl)

add_library(XNVCtrl STATIC NVCtrl.c)

find_package(X11 COMPONENTS Xext REQUIRED)

target_link_libraries(XNVCtrl PUBLIC X11::X11 X11:Xext)

include(GNUInstallDirs)
file(GLOB headers "${CMAKE_CURRENT_LIST_DIR}/*.h")
set_target_properties(XNVCtrl PROPERTIES PUBLIC_HEADER "${headers}")

install(TARGETS XNVCtrl 
        PUBLIC_HEADER
          DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/X11")
# Seems not to be used by libXNVCtrl
# if(NOT NV_VERSION)
    # message(FATAL_ERROR "Variable NV_VERSION must be passed by the portfile!")
# endif()
# add_compile_definitions(NV_VERSION=${NV_VERSION})

# if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(AMD64|x86_x64|x64)$")
    # add_compile_definitions(NV_X86_64 NV_ARCH_BITS=64)
# elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i386|i486|i586|i686|x86)$")
    # add_compile_definitions(NV_X86 NV_ARCH_BITS=32)
# elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(armv7l|ARM)$")
    # add_compile_definitions(NV_ARMV7 NV_ARCH_BITS=32)
    # add_compile_definitions(NV_GNUEABI)
# elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|ARM64(EC)?)$")
    # add_compile_definitions(NV_ARMV7 NV_ARCH_BITS=32)
# elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^ppc64le$")
    # add_compile_definitions(NV_PPC64LE NV_ARCH_BITS=64)
# endif()

# if(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    # add_compile_definitions(NV_BSD)
# elseif(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
    # add_compile_definitions(NV_SUNOS)
# elseif(UNIX)
    # add_compile_definitions(NV_LINUX)
# endif()

