vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nothings/stb
    REF af1a5bc352164740c1cc1354942b1c6b72eacb8a # committed on 2021-09-10
    SHA512 5937baa1a9b7342ddc0e41c37ba0ea6b0c878f670a81b55bb124681e6b5e381fdc1d9557c96637e3ba082d6d968ed67a78b47f16aa5555c1c43394d1f9e57f2d
    HEAD_REF master
)

# originally deleted due to patent US6867776, but it has expired and it has yet to be restored
# see https://github.com/nothings/stb/commit/59e7dec3e8bb0a8d4050d03c2dc32cf71ffa87c6
vcpkg_download_distfile(
    STB_PERLIN_H
    URLS "https://raw.githubusercontent.com/nothings/stb/2bb4a0accd4003c1db4c24533981e01b1adfd656/stb_perlin.h"
    FILENAME stb_perlin.h
    SHA512 9dbc77a530ea368a47988393c7228ffaa8622ce5ffd83770306eaa6282bf289f7f6e55f4a4a5c746798e8c8a49e180344fd8837983ec734664abf9077e37d39f
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} "${STB_PERLIN_H}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindStb.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
