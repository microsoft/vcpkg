set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ABRG-Models/morphologica
    REF "v${VERSION}"
    SHA512 9807f43af9cb5449468e4708e66b6c472ab412519a4e6bba190ae7b2f52888914c2194ef874a9603548a8a7ace27068a43c1519523012cc62ea1cf7e11a0fb81 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
