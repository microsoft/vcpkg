vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coveooss/hareflow
    REF "v${VERSION}"
    SHA512 96138675a37e381db97d963b339ab2d6472573d0e1d215bb485141d1a92be0c9658db1abb849d6e7849b396e9a877e5f0ed2ce332b68b44b7dda21536733158a
    HEAD_REF main
    PATCHES
        fix-asio-error.patch
)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(rpath "@loader_path")
else()
    set(rpath "\$ORIGIN")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_INSTALL_RPATH=${rpath}"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
