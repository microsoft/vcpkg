#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF v2.6.0
    SHA512 767884f968c8992f77a89d8d8ec253f449ef4115b421b16a38f4c9359ee43535e46cada8a5e3f9ade86a8de05bed4f792776a90cf4e6a143280c52066baca9d9
)

file(INSTALL
    ${SOURCE_PATH}/src/entt
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt)
