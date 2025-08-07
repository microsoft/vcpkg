set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Simple-Robotics/proxsuite
    REF "v${VERSION}"
    SHA512 4c732b58fe969fec51ba68b63029db63fa13f74500d8e46547f45f9ff4458ed43967b2085ac8719d3f0c22edda2ca945a75714655566424be805fa2e0bd9c54a
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH MODULES_SOURCE_PATH
    REPO jrl-umi3218/jrl-cmakemodules
    REF b3c2af1b68686dc9d5f459fb617647e37a15a76d
    SHA512 c37a67f8e74a1fd28147ba60169aa88e1901d044328f07d76a3e91e28fbd6c5a865af7ff378fd7358216ad4de0e39b3d7f158179d99be8c6b7f99f8d67be0c2b
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake-module")
file(RENAME "${MODULES_SOURCE_PATH}" "${SOURCE_PATH}/cmake-module")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_WITH_VECTORIZATION_SUPPORT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
