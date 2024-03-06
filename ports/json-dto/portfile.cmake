vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/json_dto
    REF "v.${VERSION}"
    SHA512 18e135c5a45c4421e6ae17955e042056890270717963008c4e0cba94f6dfe240fa7ea84991319ff88359abf0688ca32ed7c9783e575eca4a20b5694558a49c3d
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

