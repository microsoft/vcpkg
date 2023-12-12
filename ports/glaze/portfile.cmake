if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang or GCC 10+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 8ca16d2f63a6a5ec866cd65f649b8f80ab0507a54b6128d26d8e355bc8a8b4202051f7d2146fbcf3d2e0b5f58f069fdf7e4fe116f7e6bb19671b95b4285fc699
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dglaze_DEVELOPER_MODE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
