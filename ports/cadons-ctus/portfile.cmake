vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Cadons/ctus
        REF 1.0.0
        SHA512 efc633effdbcf0616519ef72a83bd511cc3e9a6e208454292aefef0eea75a9953cebd78c9567b830d12b1faa3b78a767bfe9fc57e293748b9333ac2055f7d07d
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME cadons-ctus
        CONFIG_PATH lib/cmake/ctus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
