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
    REF dab5060005facc38ef6500496ae7f7bd90e4fdb7
    SHA512 42b656a9d6b8091aaed5729658d7dd94064a9c9c43ad33ca474917b0830b760ee81a37a6eec84848d8aa6784d01568649f036383a8953c3e1de2616b053c682e
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
