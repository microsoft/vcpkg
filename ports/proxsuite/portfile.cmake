set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Simple-Robotics/proxsuite
    REF "v${VERSION}"
    SHA512 5c356826c24d26c1f51a0b78fee3cb9adef9406911e4862470bfaf050a18b1aa818e7aeda64c489da319c80fe10edf7ae077f31d350bed9e2129910aec637436
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH MODULES_SOURCE_PATH
    REPO jrl-umi3218/jrl-cmakemodules
    REF 30795190916d0297092e37bc1f7b50f5d76fc09c
    SHA512 fa5ce0e1e2a341c243c8abc3b0b42c14b39780f2e310250e5e234e902bb7cd1b8b6faacd3ed958836698894d5d79764ca30e50e62dfcd93b95b729d2883d7140
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
