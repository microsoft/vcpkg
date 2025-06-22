vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fredemmott/magic_args
    REF "v${VERSION}"
    SHA512 028800e35321bcee19b72933715a4a7c1b21e71cd77be86c08101a4971df892800ae18ece9e8ee155f1a2b570ecd7c3b8b6d6236bf2d4e4262c467cde8d71756
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=FF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
