include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sobjectizerteam/json_dto-0.2
    REF v.0.2.6
    SHA512 f6562b6177c941a9b898013eacb4bd78f2b8d460a82b773824bf51e106a92c27c52dca4ab6dd07a2d5e063ca3442a20c27dfd80bdcd78207e65f328b95972890
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

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/json-dto")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/json-dto)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/json-dto/LICENSE ${CURRENT_PACKAGES_DIR}/share/json-dto/copyright)
