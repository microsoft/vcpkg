# ports/webcraft/portfile.cmake

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adityarao2005/WebCraft   # <--- CHANGE THIS to your actual User/Repo
    REF 8eaab1781be6617fead4c234cb3d6fddd730e2c6                         # <--- The tag/commit you want to release (can be empty if only using --head)
    SHA512 138ffb972b0dad20f8db5f55ff6033bb782548e2c9e2f5fce43232d01f3cdab3324e7cc3572b95fc527a3222461fcffdf320000998205559e4fd2edefc2b6e27
    HEAD_REF main                      # <--- The branch to use when building with --head
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWEBCRAFT_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME WebCraft 
    CONFIG_PATH share/WebCraft
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
