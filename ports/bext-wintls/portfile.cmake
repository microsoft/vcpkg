vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO laudrup/boost-wintls
    REF "v${VERSION}"
    SHA512 b63f2634b194b9663376786ec788fd7ae1aa8281ab01899071c985311b694cc9655abb893e1b46dea7b1e7fca767fd236795b25ce1520af1b236a08589df5ae0
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/boost/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
