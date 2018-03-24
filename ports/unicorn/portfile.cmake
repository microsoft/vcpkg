include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "WindowsStore not supported")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "unicorn can currently only be built with /MT or /MTd (static CRT linkage)")
endif()

# Note: this is safe because unicorn is a C library and takes steps to avoid memory allocate/free across the DLL boundary.
set(VCPKG_CRT_LINKAGE "static")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF 9a01ae8379b0a4bc37cf50f7aeba63fddeb523c4
    SHA512 04d5e850bc1ba36856052be5a4e2a433db8d229ae90b2fbf6a5bf32c9dc86829518a8882d331d0bc7d42a23e9f5c43d6609a20dcca388c717940c081ff21b3a4
    HEAD_REF master
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(UNICORN_PLATFORM "Win32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(UNICORN_PLATFORM "x64")
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/msvc/unicorn.sln"
    PLATFORM "${UNICORN_PLATFORM}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(INSTALL "${SOURCE_PATH}/msvc/${UNICORN_PLATFORM}/Release/unicorn.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/msvc/${UNICORN_PLATFORM}/Release/unicorn.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/msvc/${UNICORN_PLATFORM}/Debug/unicorn.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${SOURCE_PATH}/msvc/${UNICORN_PLATFORM}/Debug/unicorn.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    file(INSTALL "${SOURCE_PATH}/msvc/${UNICORN_PLATFORM}/Release/unicorn_static.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/msvc/${UNICORN_PLATFORM}/Debug/unicorn_static.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

file(
    INSTALL "${SOURCE_PATH}/msvc/distro/include/unicorn"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    RENAME "unicorn"
)
file(
    INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unicorn"
    RENAME "copyright"
)
file(
    INSTALL "${SOURCE_PATH}/COPYING_GLIB"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unicorn"
)
