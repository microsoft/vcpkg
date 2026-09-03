string(REPLACE "." "_" LWIP_VERSION_UNDERSCORE "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lwip-tcpip/lwip
    REF "STABLE-${LWIP_VERSION_UNDERSCORE}_RELEASE"
    SHA512 50da620efa071b8ed0180941d0873e4cc6784d03b028ed08a717a0d3dc7212fc843686a2fe5b19275f95d770927913b401a52ef40c94eec545f78906216123df
    HEAD_REF master
    PATCHES
        disable-filelist-side-effects.patch
)

# lwIP is configured by the consuming application through lwipopts.h and a
# platform-specific port. Consequently, its sources must be compiled as part
# of the application instead of as a preconfigured library in this port.
file(
    INSTALL
        "${SOURCE_PATH}/src"
        "${SOURCE_PATH}/contrib"
        "${SOURCE_PATH}/BUILDING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

# Install a conventional copy of the public headers as well. The copy under
# share/lwip is retained because the upstream Filelists.cmake expects the
# original source-tree layout.
file(
    INSTALL "${SOURCE_PATH}/src/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    FILES_MATCHING PATTERN "*.h"
)

file(
    INSTALL
        "${CMAKE_CURRENT_LIST_DIR}/unofficial-lwip-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-lwip"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
