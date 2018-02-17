include(vcpkg_common_functions)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
  message(FATAL_ERROR "Error: redshell does not support the ARM architecture.")
endif()

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: redshell does not support UWP builds.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message("Redshell only supports dynamic library linkage")
  set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "Redshell only supports dynamic CRT linkage")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/redshell)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Innervate/red-shell-cpp
    REF 1.1.2
    SHA512 9e0705508928efed5ae5c216316cb0429090cd7131ca7993f585eaf26bccd1e18b93dfeaff0406c64921b06c8312c0d147024af1c29e6003ff35556cda36e57c
    HEAD_REF master
)

# Header .h
file(COPY
    "${SOURCE_PATH}/include/RedShell.h"
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/redshell
)

# Debug .lib
file(COPY
    "${SOURCE_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/debug/RedShell.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

# Release .lib
file(COPY
    "${SOURCE_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/RedShell.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

# Debug .dll
file(COPY
    "${SOURCE_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/debug/RedShell.dll"
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)

# Release .dll
file(COPY
    "${SOURCE_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/RedShell.dll"
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)

# Copyright
file(COPY
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/redshell/copyright
)
