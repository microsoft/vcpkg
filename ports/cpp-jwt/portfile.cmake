vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arun11299/cpp-jwt
    REF 0d662241daf54d8b9911bf8f54784bd2da5a3d19
    SHA512 06a508872f0920ed078b5f9250fe1d5011ad41773c4b8631d7c7947d9f9be4d5e24ca4a7d98c79eb8cd14118effa8893a862089bdc90af6d75031bbb9fc2ee5f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DCPP_JWT_BUILD_EXAMPLES=off
        -DCPP_JWT_BUILD_TESTS=off
        -DCPP_JWT_USE_VENDORED_NLOHMANN_JSON=off
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
