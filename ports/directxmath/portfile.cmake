vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMath
    REF jan2021
    SHA512 ca0ce940c80d350597ec3f2bb336006f7851bb8917dd94b69238c7a4e8a0324ef8d878d94ba95426d458e6912a64567655f9d17a9c6f1ced0d6fdcc99536912f
    HEAD_REF master
    FILE_DISAMBIGUATOR 1
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
