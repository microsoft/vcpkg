vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/json_dto
    REF "v.${VERSION}"
    SHA512 476091f78f0c3b2dd0da2a83964fbf280259c163f058b2578eb17055fce0a2162e14bbea12e3bbdef93afda1f1c9f48a91e570f8f5e0f53a58a4f7188ebd437e
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

