vcpkg_fail_port_install(ON_TARGET "linux")

include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

if(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
  set(ignition_msgs_CROSSCOMPILING ON)
else()
  set(ignition_msgs_CROSSCOMPILING OFF)
endif()

if(CMAKE_HOST_WIN32)
    set(HOST_EXECUTABLE_SUFFIX ".exe")
else()
    set(HOST_EXECUTABLE_SUFFIX "")
endif()

# This port needs  to generate protobuf messages with a custom plugin generator,
# so it needs to have in Windows the relative protobuf dll available in the PATH
if(NOT ignition_msgs_CROSSCOMPILING)
  set(path_backup $ENV{PATH})
  vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
  vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)
  set(CMAKE_OPTIONS "-DINSTALL_IGN_MSGS_GEN_EXECUTABLE:BOOL=ON")
  set(TOOL_NAMES_OPTION TOOL_NAMES ign_msgs_gen)
else()
  if(NOT EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/${PORT})
    message(FATAL_ERROR "Cross-targetting ${PORT} requires the x86-windows ${PORT} to be available. Please install ${PORT}:x86-windows first.")
  endif()
  set(CMAKE_OPTIONS "-DIGN_MSGS_GEN_EXECUTABLE=${CURRENT_INSTALLED_DIR}/../x86-windows/tools/${PORT}/ign_msgs_gen${HOST_EXECUTABLE_SUFFIX}")
  set(TOOL_NAMES_OPTION "")
endif()

ignition_modular_library(NAME msgs
                         VERSION "5.1.0"
                         SHA512 db485f737c465b310602342a1a751c561473e330eb18d1b322b32d13de246536fe6a7efdf245faaaa9be1c9bfce662b2d39d1bb7cffc37e52690893cb47cc2ee
                         PATCHES
                           "01-protobuf.patch"
                           # Backport https://github.com/ignitionrobotics/ign-msgs/pull/60
                           "02-support-crosscompilation.patch"
                         CMAKE_OPTIONS "${CMAKE_OPTIONS}"
                         ${TOOL_NAMES_OPTION})

# Restore old path
if(NOT ignition_msgs_CROSSCOMPILING)
  set(ENV{PATH} "${path_backup}")
endif()
