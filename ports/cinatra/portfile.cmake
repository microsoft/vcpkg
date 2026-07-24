set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 dfc58ab01ea962f007e8922a4614b3017f4e6da03d5f79edf3b8ee2750a23803b20fc905ffb1600ee7d2440339b84543c61ddae58e13a587d357db8372baf510
    HEAD_REF master
    PATCHES
        fix-picohttpparser-include-guard.patch
)

# Install Cinatra’s headers
file(INSTALL
    "${SOURCE_PATH}/include/cinatra"
    "${SOURCE_PATH}/include/cinatra.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
