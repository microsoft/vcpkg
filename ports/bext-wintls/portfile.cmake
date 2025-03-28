vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO laudrup/boost-wintls
    REF "v${VERSION}"
    SHA512 09fda0e2f1b212137c75fa58bd9f4d8df8469fb1381c82c639db9de54ab187119743534e117bd5421329d5c578a21546c4448042f0cad810e73e3a999be5c6db
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/boost/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
