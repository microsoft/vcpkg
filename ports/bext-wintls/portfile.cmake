vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO laudrup/boost-wintls
    REF "v${VERSION}"
    SHA512 740f25c4ffb657cf96aa45346b7acb4e0d63025f443977cc1c6eacb08defe0519776d1a2e20df00e72d9346f3d03d5d3e53e2f93371c290e6041979670a6ca66
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
