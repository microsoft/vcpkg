vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMath
    REF jan2021
    SHA512 7956082cd950e1b854bc3335635f8688c04268f74b9e8167896a50a9b64ffbc0a87e93a2f852d0224f22a57ff01b88a2af746613460897250d8b841c307931a8
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(
        SAL_HEADER
        URLS "https://raw.githubusercontent.com/dotnet/corert/master/src/Native/inc/unix/sal.h"
        FILENAME "sal.h"
        SHA512 1643571673195d9eb892d2f2ac76eac7113ef7aa0ca116d79f3e4d3dc9df8a31600a9668b7e7678dfbe5a76906f9e0734ef8d6db0903ccc68fc742dd8238d8b0
    )

    file(INSTALL
      ${DOWNLOADS}/sal.h
      DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXMath)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
