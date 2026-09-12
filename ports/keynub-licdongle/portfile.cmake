# The library ships prebuilt; the port installs the files for the target platform
# from the SDK repository and the CMake package config that goes with them.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AB-KeyNub/KeyNub-SDK
    REF v${VERSION}
    SHA512 6c650b3ccbb70f7813d9df965c35be5cac953b7301504ac1dd43b9a31785be3e67201f87f45a30da52e76fe206a535b41550276cd097eb7edc18eb8ebffd6bae
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(os "win")
elseif(VCPKG_TARGET_IS_LINUX)
    set(os "linux")
elseif(VCPKG_TARGET_IS_OSX)
    set(os "osx")
else()
    message(FATAL_ERROR "No prebuilt keynub_licdongle library for ${VCPKG_CMAKE_SYSTEM_NAME}")
endif()
set(natives "${SOURCE_PATH}/natives/${os}-${VCPKG_TARGET_ARCHITECTURE}")
if(NOT IS_DIRECTORY "${natives}")
    message(FATAL_ERROR "No prebuilt keynub_licdongle library for ${os}-${VCPKG_TARGET_ARCHITECTURE}")
endif()

file(INSTALL
    "${SOURCE_PATH}/include/licdongle.h"
    "${SOURCE_PATH}/bindings/flat/licd_flat.h"
    "${SOURCE_PATH}/bindings/labview/licd_labview.h"
    "${SOURCE_PATH}/bindings/cpp/licdongle.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# One prebuilt set serves both configurations.
if(VCPKG_TARGET_IS_WINDOWS)
    set(shared "${natives}/keynub_licdongle.dll" "${natives}/keynub_licdongle_flat.dll")
    set(implib "${natives}/keynub_licdongle.lib" "${natives}/keynub_licdongle_flat.lib")
    foreach(cfg "" "/debug")
        file(INSTALL ${shared} DESTINATION "${CURRENT_PACKAGES_DIR}${cfg}/bin")
        file(INSTALL ${implib} DESTINATION "${CURRENT_PACKAGES_DIR}${cfg}/lib")
    endforeach()
else()
    file(GLOB shared "${natives}/libkeynub_licdongle.*" "${natives}/libkeynub_licdongle_flat.*")
    list(FILTER shared EXCLUDE REGEX "_static\\.a$")
    foreach(cfg "" "/debug")
        file(INSTALL ${shared} DESTINATION "${CURRENT_PACKAGES_DIR}${cfg}/lib")
    endforeach()
endif()

file(INSTALL
    "${SOURCE_PATH}/keynub_licdongleConfig.cmake"
    "${SOURCE_PATH}/keynub_licdongleConfigVersion.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/keynub_licdongle")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/BINARY-LICENSE.txt"
    "${SOURCE_PATH}/NOTICE"
    "${SOURCE_PATH}/THIRD-PARTY-NOTICES.txt")
