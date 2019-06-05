include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sobjectizerteam/json_dto-0.2
    REF v.0.2.8
    SHA512 50a2d8d31f4cf67bdf84a58bae5f95642f4be571e8e052a48830be119d5e3c4ddbb19c5ac97fc0f8383c9958d64ec9be4ce23019c1da4f2cbf4b8ddbf23f5ad7
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
