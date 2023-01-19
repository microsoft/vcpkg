vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF v3.7.1
    SHA512 7acf038e0277cea9470520dd469a266a1cbe1f03046b7ee1d25766f04f45f1a9d2ca40f50a2de084ee321626ceda4ee6de039b50386757138cf5a4c5aea5c9f3
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
