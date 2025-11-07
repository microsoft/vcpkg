vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF 1.0.0
    SHA512 667c51d60c16a47b799555740e9b8578a626af77c50745e0f3704779b70eb99338dabfb78e29b9b3e805e22348048b9887ea3a83d3b0591c87c37a21a495dcd0
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/src
    OPTIONS -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
