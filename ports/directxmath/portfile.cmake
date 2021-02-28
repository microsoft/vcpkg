vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMath
    REF jan2021
    SHA512 8288f9e4d30b4947e98122f298ca25b8e2f82091c1257d3a0fd4d8de44c4c9a97d4549c105b388afbefad11ad6f30429e875e3e70eb4aa7865be6d4c08d6d1f3
    HEAD_REF master
    FILE_DISAMBIGUATOR 2
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
