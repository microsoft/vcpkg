vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMath
    REF may2022
    SHA512 685e5a0cdd1bc66a5df628f864eae0959d5d5abdcc7e9242ea7af1d5b011cb0705447c366bacd456db96e39dac8cf0e0618a6e055a7db821cdcfa20a1ad08868
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxmath/cmake)

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
