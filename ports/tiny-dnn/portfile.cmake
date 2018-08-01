#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiny-dnn/tiny-dnn
    REF a8de26ad40d955908c5ec4fc946c3c67dd381c6c
    SHA512 4dc89f038a4dd4bd706077f1c72afdd503fa41edc3b1eb0e8c459c55c9a658d17add98e66dac48914e253df121818da3d277b1a0fac945f22efe9d76d2f9476e
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)
