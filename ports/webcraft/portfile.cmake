# ports/webcraft/portfile.cmake

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adityarao2005/WebCraft   # <--- CHANGE THIS to your actual User/Repo
    REF v1.0.1                         # <--- The tag/commit you want to release (can be empty if only using --head)
    SHA512 e6ac8bc32167d6b8f367d33236af8178213149131c35ece167a2d0098844542126a4eca93f76d8a1e9e94e0811cdd337ade448c32ebdb27583c4c7ec3e808557                           # <--- Keep as 0. We will get the real hash in Step 3.
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
    CONFIG_PATH share/webcraft
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
