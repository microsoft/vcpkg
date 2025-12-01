vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/poolparty
    REF "v${VERSION}"
    SHA512 ae542b2be6134cf58926e4ede8840bff560c427d45c07fadb7dc465112712df80a89569f5ebd4d57c6045cdd74380a65ed296f32c8904531327207aa7281c1b6
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
