#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF v2.7.2
    SHA512 334b94ef142bb234204315e47c9783f55c7639c59a214b772ce76c6b7cf4008280ab6762a3cf6049f51932773f5ae62e45d9423efe0dd5043b20103b1f857167
)

file(INSTALL
    ${SOURCE_PATH}/src/entt
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt)
