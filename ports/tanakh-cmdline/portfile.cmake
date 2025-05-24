set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tanakh/cmdline
    REF e4cd007fb8f0314002d9a5b4d82939106e4144e4
    SHA512 0d69105d79672daaf0194f15479794ab1b62c4ae270eb56e6664bc65e4cf4ebbc0d5bf76bc92ecea23fb401121165f9e8a79e39136b34ef680444208294ecf60
    HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${SOURCE_PATH}/cmdline.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/tanakh-cmdline"
)

