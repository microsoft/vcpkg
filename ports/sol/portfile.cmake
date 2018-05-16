include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF f8ee7abe527a9e8414fc4965e5cbd0f8395fbeae
    SHA512 6bf090deb3b664e9585672b8f85275b76c53eddc7fe206ceec943522195bb726e976c946b59cc23863bc7e0feab36f4fe1a6a7a5dae3f9c2ec5c64060014afbf
    HEAD_REF develop
)

file(INSTALL ${SOURCE_PATH}/single/sol/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sol RENAME copyright)
