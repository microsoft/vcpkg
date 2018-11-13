#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiny-dnn/tiny-dnn
    REF 1aec6a1ece0ba7a5e018a070bd52e045d49d1411
    SHA512 173607504cf4e6cc5f70febbfc305dd1fe7168bc6eff82c90d202caa342c3aecf13a3c3cc7f70f4f9674b5649d3a14180fb682742025c408e3e4ea9ec6b99f8a
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)
