vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arun11299/cpp-jwt
    REF v${VERSION}
    SHA512 765579abef09774e396bdf539e1585d383aabe50b76c7d7643ede85187a665a3420db2ad90fee1ca2a9003965b777816b8594dc10b08772db58c8068cbe64a09
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

vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
