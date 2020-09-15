vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/json_dto
    REF bc4e55984f033c677c8a298af86ba72ea5ef6072 # v.0.2.10
    SHA512 1128e6290ff42600a93aed7c7208ace7e977f259654e580f920db612dcef4fe714bf8e0ed237bbf9e689f66959ab56ab27c9b7477504d71d205f3500d3bce07a
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DJSON_DTO_INSTALL=ON
        -DJSON_DTO_TEST=OFF
        -DJSON_DTO_SAMPLE=OFF
        -DJSON_DTO_INSTALL_SAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/json-dto)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
