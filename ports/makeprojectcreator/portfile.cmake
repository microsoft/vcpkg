# MPC has no releases of its own, it is tagged together with each ACE/TAO release
string(REPLACE "." "_" VERSION_TAG "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DOCGroup/MPC
    REF "ACE+TAO-${VERSION_TAG}"
    SHA512 ab402fdc632546c28a6be45f7b0d6e47c63930f8c89e64b6f1e4a6c898d9ac5596b035e14505d28fb2d4d2e283b9d7dd59366c71a8f1c90784446b576bd88c93
    HEAD_REF master
    PATCHES
        zlib.patch
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/.github"
    "${SOURCE_PATH}/.gitignore"
    "${SOURCE_PATH}/_typos.toml"
)

file(INSTALL "${SOURCE_PATH}/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    USE_SOURCE_PERMISSIONS
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/docs/LICENSE")
