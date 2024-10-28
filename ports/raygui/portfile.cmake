#header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raygui
    REF "${VERSION}"
    SHA512 8e59889af6b6163b9ff9930ae79bdfaab5015e39279d1a50d3f74c0f50b12b2015fdf17016b04d2c4f66420f4e631b25a51ede5c1627dfcde269457f55f34ff1
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/raygui.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
