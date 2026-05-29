vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d99kris/rapidcsv
    REF "v${VERSION}"
    SHA512 ac77bd307a01e891764d12e9c0632e3ef3778297b21c00b176172f3fa3e818bea71a53ba557f8a5d1ac52ed4c2f32e0bba8f8992a7d8f0f821ac9f2983ffa1a5
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
