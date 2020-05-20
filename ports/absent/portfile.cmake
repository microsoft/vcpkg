vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rvarago/absent
    REF 0.3.0
    SHA512 e576a77e7305597ec931c4302a60355241fc8f2bb823d92add1079ea63e8ade39da6f5853135c1e68e3cc4c460dad7a67a76c3c451e645f05a39c2435b048f87
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)

