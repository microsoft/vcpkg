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

ignition_modular_library(NAME msgs
                         VERSION "1.0.0"
                         # See https://bitbucket.org/ignitionrobotics/ign-msgs/issues/33/the-ignition-msgs1_100-tag-does-not-match
                         REF ignition-msgs_1.0.0
                         SHA512 3a270f0ac988b947091d4626be48fe8cfed5ddfde5a37b9d0f08fddcbf278099ab231fca11e2dd2296ca54e0350ea14e3f685dc238f0827f18f10ab7b75039de
                         # Fix linking order of protobuf libraries (backport of https://bitbucket.org/ignitionrobotics/ign-msgs/pull-requests/151)
                         PATCHES fix-protobuf-static-link-order.patch)
