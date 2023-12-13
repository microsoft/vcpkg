vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO laudrup/boost-wintls
    REF "v${VERSION}"
    SHA512 b2973148f53f036108783ea6c30fca5f5055efc3676a9df2d1bf527399f757ac2f319f8637646904820e5280a8be48cf8369a3d2b6a3879afc0aa4463c77ea06
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/boost/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
