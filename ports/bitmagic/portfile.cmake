# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlk00/BitMagic
    REF "v${VERSION}"
    SHA512 49e1fe4b1628d54ca6b45d8b2a5a1f31aaec67a949630b3ca60c2e70af536d7954fbf8577cf26981436339818ddf243c5c2579585755f42c9dc6a87e0e6d9548
    HEAD_REF master
        fix-clang.patch #https://github.com/tlk00/BitMagic/commit/fab01f43eca266bf56efb1aca659773c911a83fb
)

file(GLOB HEADER_LIST "${SOURCE_PATH}/src/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
