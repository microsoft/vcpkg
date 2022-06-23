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

ignition_modular_library(NAME msgs
                         VERSION "1.0.0"
                         # See https://bitbucket.org/ignitionrobotics/ign-msgs/issues/33/the-ignition-msgs1_100-tag-does-not-match
                         REF ignition-msgs_1.0.0
                         SHA512 18475cc76cc3b58e451faf7a57a0145a9b419cf3e4312627202d96982b066df48cbabcc9991b79a176c5180b90f019dc30114286ad5562c483759052cf63d945
                         # Fix linking order of protobuf libraries (backport of https://bitbucket.org/ignitionrobotics/ign-msgs/pull-requests/151)
                         PATCHES fix-protobuf-static-link-order.patch)
