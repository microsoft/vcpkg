include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/json_dto
    REF v.0.2.9
    SHA512 6a34e24c784f002bb3b025af93dc24c485090bc1f9ce55472a54929fe58fa4b1bf6f1ff5d2fea9fb33c8bc87aeae6a926cbb2d196f1e7172bb1a356935f3a7b6
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
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/json-dto)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/json-dto/LICENSE ${CURRENT_PACKAGES_DIR}/share/json-dto/copyright)

