#header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raygui
    REF "${VERSION}"
    SHA512 c1d970d98fb721203934fcc3b50d8185271c43e426112bfd0d350899b76586e1cc82dacf4e676827725cff75bc35c7e7e51acbfb8db47f92ad67ee58c9560778
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/raygui.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
