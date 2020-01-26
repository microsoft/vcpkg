include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

# Explicitly disable cross-compilation until the upstream discussion
# https://bitbucket.org/ignitionrobotics/ign-msgs/issues/34/add-support-for-cross-compilation is solved
if(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(ignition_msgs_CROSSCOMPILING ON)
elseif(CMAKE_HOST_WIN32 AND VCPKG_CMAKE_SYSTEM_NAME)
    set(ignition_msgs_CROSSCOMPILING ON)
else()
    set(ignition_msgs_CROSSCOMPILING OFF)
endif()

if(ignition_msgs_CROSSCOMPILING)
    message(FATAL_ERROR "This port does not currently support triplets that require cross-compilation.")
endif()

# This port needs  to generate protobuf messages with a custom plugin generator,
# so it needs to have in Windows the relative protobuf dll available in the PATH
set(path_backup $ENV{PATH})
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)

ignition_modular_library(NAME msgs
                         VERSION "1.0.0"
                         # See https://bitbucket.org/ignitionrobotics/ign-msgs/issues/33/the-ignition-msgs1_100-tag-does-not-match
                         REF ignition-msgs_1.0.0
                         SHA512 15261d9c82c05952b1b7dfc50346e73ab041bf6e2e5a63698e17bfa36b2d261aad2777f770f6dccd0d58eb9c90979fe89a7371dc2ec6050149bf63cafc4f6779
                         # Fix linking order of protobuf libraries (backport of https://bitbucket.org/ignitionrobotics/ign-msgs/pull-requests/151)
                         PATCHES fix-protobuf-static-link-order.patch)


# Restore old path
set(ENV{PATH} ${path_backup})
