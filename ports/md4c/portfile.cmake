vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mity/md4c
    REF "release-${VERSION}"
    SHA512 30607ba39d6c59329f5a56a90cd816ff60b82ea752ac2b9df356d756529cfc49170019fae5df32fa94afc0e2a186c66eaf56fa6373d18436c06ace670675ba85
    HEAD_REF master
    PATCHES
        "cmake.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_MD2HTML_EXECUTABLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/md4c")
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
