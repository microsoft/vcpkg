vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arun11299/cpp-jwt
    REF 4b66cf74e5ece16e7f7e8c3d8c0c63d01b4cc9aa
    SHA512 b66c6f482feb03621926ee6739d081b7f03dcc963a57ba59fce62fb61a3f5082d4eb75db682b567d299ea6e80f37078c033b31c966cbad6f4c234850b0b81cd0
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
