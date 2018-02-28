#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiny-dnn/tiny-dnn
    REF 17cb7ae1d130feda9a1612608ac0677cc3254bf8
    SHA512 fbd3cf94b393a4f2aacb0770b5611681b6445f0e16905435c2ec597cfc1c37e3ba7af8bb3b43146e0b2b6cd0fe4df17040f4d72dfb1d4aa50d6310350f655a46
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include)


file(COPY ${CURRENT_BUILDTREES_DIR}/src/tiny-dnn-dd906fed8c8aff8dc837657c42f9d55f8b793b0e/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)