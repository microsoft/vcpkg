#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiny-dnn/tiny-dnn
    REF 1c5259477b8b4eab376cc19fd1d55ae965ef5e5a
    SHA512 756b8e3d5d00b44973bbae2c0bedbe15206bce479dc70ae5fc89f455772deadc05503afd7abcae2048aeabefd7a45cba0fae38555df7e0d9eb33e9feed21b099
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)
