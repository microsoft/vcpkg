vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hidefromkgb/gif_load
    REF 74b674de2704bc1b20fc3bf482a5ee3e774b67c5
    SHA512 f58b02ad62c0898865bb0c933711f52eb203c3e49b832847613a1de32330192636ddd31aacba2cefe7a7acde7c9be3c5edeea262b905b9a49bf05f4bbafddc21
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/gif_load.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-gif-load-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-gif-load")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/gif_load.h")
