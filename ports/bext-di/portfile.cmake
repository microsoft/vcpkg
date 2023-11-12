vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/di
    REF 28a356cc28877937bd29359ea5fa7daf04bd4d98 # v1.3.0
    SHA512 b15a6ff011fb5b2b2798cb01cb6efe552d6835f78be225ace0b995b8331c4177a5c5b26f15eabb8d56f97c56e9cb676452d69a8ce652780c4f858f009b9924b0
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
