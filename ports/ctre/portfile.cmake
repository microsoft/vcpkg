vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF v3.6
    SHA512 ad39da95cafa0198a14362492c083541dfe9beafae9adfdfc5ec5adc9bba7395553abd9799b414493c962c3dd25a79af8c7cc9b7af35392049e2ab9f8b679362
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCTRE_BUILD_TESTS=OFF
        -DCTRE_BUILD_PACKAGE=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/ctre")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
