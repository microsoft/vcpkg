vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/json_dto
    REF 00e5313d56d5e5ab7cd1d8635e6740d6c01552e9 # v.0.3.0
    SHA512 31d63b00029848d6983c948461619322525907dcc45bae4e07150400c62470f0aa72034db847d5d2e1626b6d820cc8a98cc5cbdfb33aee235cd06efb88816667
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/dev
    OPTIONS
        -DJSON_DTO_INSTALL=ON
        -DJSON_DTO_TEST=OFF
        -DJSON_DTO_SAMPLE=OFF
        -DJSON_DTO_INSTALL_SAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/json-dto)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

