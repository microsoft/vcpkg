vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/ndis-driver-library
    REF "release/v${VERSION}"
    SHA512 4f96c8769c9363e8e2abc89090d1342dc6b9f868c72434cd1943c3d6d52bc89195463eb7bb5aa6d128b31f1ae61a1fd5131e2fe859c1b591ef3a54de764661a3
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/src/include/ndis" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
