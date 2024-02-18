vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO soasis/static_containers
    REF e1a21217b6dba3028e6cc6bf0f9562972ea1c43d
    SHA512 ec5b98e2282e72eb09617006afaf2522a471b6eb3928c90fb878c46b7453bb94ddafb19cb4738c5561905003d299bb23d15ebf71c555259b5e500594fbadd97f
    HEAD_REF main
    PATCHES fix-cmake.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
