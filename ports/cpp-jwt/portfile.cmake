vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arun11299/cpp-jwt
    REF v1.4
    SHA512 e2c7433599347e0aa34261415441c61ed152e986a2699438d2733c84d56c4005e98cffb430335ff6ac3eed99bd19640d57e300924624d827487ffe85139118c5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DCPP_JWT_BUILD_EXAMPLES=off
        -DCPP_JWT_BUILD_TESTS=off
        -DCPP_JWT_USE_VENDORED_NLOHMANN_JSON=off
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/include/jwt/test")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
