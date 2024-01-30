vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/di
    REF "v${VERSION}"
    SHA512 2371415df0b6569861d60c32908afb6fae8bfa221ad4153eeb7f60143f8449eca6c81b57067d5009b8cd85e31c04ede554fdee23008ddeffa4e7746856e250ae
    HEAD_REF cpp14
)

file(INSTALL ${SOURCE_PATH}/include/boost
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_download_distfile(LICENSE
    URLS https://www.boost.org/LICENSE_1_0.txt
    FILENAME "di-copyright"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)
vcpkg_install_copyright(FILE_LIST "${LICENSE}")
