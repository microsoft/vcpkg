#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF v2.7.1
    SHA512 6db7aa43194dd30026f409ee7f1012d48c3812ec99fc525864527142e5b94bef3950759874d7afcafa264af1c7ccfd39979c550c641e942cc6871e537938d508
)

file(INSTALL
    ${SOURCE_PATH}/src/entt
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt)
