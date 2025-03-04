set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ABRG-Models/morphologica
    REF "v${VERSION}"
    SHA512 222c9d3a479f5288ecb3f3d8f05f39e0e0981c397b1c6472f022dc7ebc8a20f03cf048208216f7f90c441b3eb2ea49c625e587e0c2c469bef32707abec7c0e42 
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
