set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinygltf
    REF "v${VERSION}"
    SHA512 a97a1da28a132e4012641fdb10ae5bc5055a49a556ab975eae3696f4c80a287423358f3408a841f3e188df578a172b0c814526511e227daa247ed61c80b9edf4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DTINYGLTF3_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
