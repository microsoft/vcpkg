set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO saadshams/nanojson
        REF "${VERSION}"
        SHA512 6c1b4c5b43f04b01c94983e89ff6ebcc78cfe8ce060a89a7e2afb8059e50ecd6f3e345189061370f3af7a4cead15da9a29dc8f10f95c88bbce8d195b76936742
        HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOJSON_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/nanojson")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
