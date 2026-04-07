# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_stack
    REF fd497417c17119dd73068d69749b67a6f9ff00b7 # 2.0.13
    SHA512 77796cb7e9e008744f28f6de8ab72afa3366ea578be9aec36a4b5eb623cc1efaafb26ebf55456d311b9ce11e6e0e61ba9c030ecf0c7df63c185a13ff2fe2f39b
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_stack.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
