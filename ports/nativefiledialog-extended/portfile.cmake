vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_minimum_required(VERSION 2022-11-10)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO btzy/nativefiledialog-extended
    REF v${VERSION}
    SHA512 3992b4e9ea87fd2f0f85c9e5952fb19b7006f2c9709f1b1c4925de329f3dc1065d2c1af851cba4afbbfa95f0ed764ec36a1f55d7a4720e813563e4e6f533024a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
