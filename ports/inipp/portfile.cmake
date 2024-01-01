vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mcmtroffaes/inipp
    REF 1.0.12
    SHA512 c96771613e9212eadd4ac468b30217851a09e193511ea38ef077b4c0039eb4b6fc90ff7a8252e8445f64e15504cbdd86a8b2e47dfe1c8e3a088221751e322304
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/inipp/inipp.h  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
