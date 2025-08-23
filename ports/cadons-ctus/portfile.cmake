vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Cadons/libtusclient
        REF 1.0.0
        SHA512 bdca3c3c8baba50f55fdc9422d349e7d20b18ca79eefc5d0681de6a9145f2901a070a0b2313e1c80052ec85170174a11338fb5e89fba71b422521c9f2c5155be
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME cadons-ctus
        CONFIG_PATH lib/cmake/cadons-ctus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
