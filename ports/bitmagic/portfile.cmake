# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlk00/BitMagic
    REF "v${VERSION}"
    SHA512 d034f66b8631d09cb0be11b96f5f12dea416ef2cfca42ed7f0865aeb65102a4951821805ec65bee793541ce1a665e5d11ba4bedb0d79956c0eee6c856afb29b2
    HEAD_REF master
    PATCHES
        fix-clang.patch #https://github.com/tlk00/BitMagic/commit/fab01f43eca266bf56efb1aca659773c911a83fb
)

file(GLOB HEADER_LIST "${SOURCE_PATH}/src/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
