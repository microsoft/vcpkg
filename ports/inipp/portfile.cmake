vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mcmtroffaes/inipp
    REF ${VERSION}
    SHA512 c1123dcda9cddd5b979fc1788c326eba6d0b2d9cec4415d7a27e6b0906eeb2d1ad68dffbf4673b90b268defc6593d32e22beac4b3619e68df4ea83ab8a15d562
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/inipp/inipp.h  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
