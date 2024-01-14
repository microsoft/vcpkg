vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spotify/annoy
    REF "v${VERSION}"
    SHA512 bf6e3095871cef2da20310f0a6260d65079cd2116b00ee39c82a6cb96d6cc80780b4f677c3746b85e7fe45672707a06c37bd8e8ecf793507584eca4760731018
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/annoy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
