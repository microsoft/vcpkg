vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMath
    REF jan2022
    SHA512 8defaa693c8b8aed05791c83b99fa73aac2fc18475b0d51337a81f7d9807b53e426fdf530ed6f1d2d0ebd259e87cc42ac881bdb168387d883998f58a5c0a4886
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

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
