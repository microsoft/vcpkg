include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "WindowsStore not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF bc34c36eaeca0f4fc672015d24ce3efbcc81d6e4
    SHA512 2edd31097a38d4270ae36f3f54b4c9385e088f85465d3c4fc7cd95162e5d4ba72b8b7d305deeb535c69dcbc15de7364150530887b29b363e087aadacce3f2f41
    HEAD_REF master
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(UNICORN_PLATFORM "Win32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(UNICORN_PLATFORM "x64")
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/msvc/unicorn.sln"
    PLATFORM "${UNICORN_PLATFORM}"
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
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
