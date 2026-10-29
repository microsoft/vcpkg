vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO conorwilliams/libfork
    REF "v${VERSION}"
    SHA512 38a8a6fe0f360f1caa123b227996490f192f8b58340ecb5d91922c15d7ca9b364031716e139a3ab0d89cd7cdf3bfb22fcf75272e76a40513c55adaf00ff6454d
    HEAD_REF main
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}" 
    OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "libfork")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
