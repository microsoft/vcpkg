#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF v2.5.0
    SHA512 a56d17c4ac832b50349293eb40c32efb079d90c9a7010589979eac5f13b97e82c032f94b87d0d7885099ee6f1857e68e064e3248c7f4d52ccca02620fd80ea25
)

file(INSTALL
    ${SOURCE_PATH}/src/entt
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt)
