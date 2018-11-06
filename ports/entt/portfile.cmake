#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF cpp14
    SHA512 aa3ced9084a0a973ed5c9384ab3950c8ed54239df7ae605600d8cd7c2774c4173d16ad5ea7442751dfbc675f881cab952844ba794fdf464710a85fc9d77a8a5d
)

file(INSTALL
    ${SOURCE_PATH}/src/entt
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt)
