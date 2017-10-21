#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiny-dnn/tiny-dnn
    REF dd906fed8c8aff8dc837657c42f9d55f8b793b0e
    SHA512 d853db7f49af1bece55337b93631c41191f3abd8287969f230330662fecc612e4e53ab789535fc6f9770ae0c8623d8e020e6036c2c804783d08f176a08c05d1b
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include)


file(COPY ${CURRENT_BUILDTREES_DIR}/src/tiny-dnn-dd906fed8c8aff8dc837657c42f9d55f8b793b0e/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)