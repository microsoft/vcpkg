# vcpkg_from_github(
    # OUT_SOURCE_PATH SOURCE_PATH
    # REPO playgithub/BasicTools
    # REF v1.0.1
    # SHA512 f692682689c0b0fcc3953a1cc157b6e1d2ce3ccab185189d6dc0807f1dd3ea2d1a9773d0b805079a30b3c8a3b0cf3ee83239ed48d7b08dc7762eba29c2033674
    # HEAD_REF master
# )

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git@github.com:playgithub/BasicTools
    REF e8f316dea25420d7971c8efd07ee43f011d1fb31
    TAG v1.0.1
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)