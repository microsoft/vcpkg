# sparrow is header only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/sparrow # 0.0.1
    REF 799b3ce5173c7731d30faf167f3dbf6c6fcab6fe
    SHA512 f9ed9b59c3510178c220716f5ef66b3112d9c79d026cfdcb05464023be6b4c4edb1d862287c9579d8eaf50a37dbb4f7cfc51d95ed077a9b8f5040c7c95fd0f63
    HEAD_REF main
    PATCHES
        0001-build-Require-CMake-3.27.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
