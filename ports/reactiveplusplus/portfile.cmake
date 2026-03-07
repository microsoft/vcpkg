vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO victimsnino/ReactivePlusPlus
    REF "v${VERSION}"
    SHA512 4350b871e0219c469469658c323d55c6df894995e61c14035da400a6f4928cbba4fb9307efad1a5db43a7a1b68c4f5d6f4bc355afd80c390258f8f2b6a196d61
    HEAD_REF v2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME RPP CONFIG_PATH share/RPP)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(GLOB_RECURSE CMAKE_LISTS "${CURRENT_PACKAGES_DIR}/include/CMakeLists.txt")
file(REMOVE ${CMAKE_LISTS})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
