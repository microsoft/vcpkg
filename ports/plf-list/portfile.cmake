# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_list
    REF b60676915e82f9e686de2550d68a1866617cbf42
    SHA512 af9e9278604caa06075ca989f082d57ea33122958fa13b45a47242c36ae588769e1b15a27ea4676e361aeff3cef69429d0cf2bbab5a782d97f90e06b00198192
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_list.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
