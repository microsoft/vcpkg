# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_indiesort
    REF fb28b3f24886253d4eaab5e05f23b8cf84238f1e
    SHA512 1f8f7b8dbb698d22e02701d6991bf5525a825ac5404bdeba7b09bc7814175fedaeedebbd6aba4db587d5d93ab14d4f3e0dbe78a098b10e9c0d4efb1bc1456026
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_indiesort.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
