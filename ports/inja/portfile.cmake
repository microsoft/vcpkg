vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/inja
    REF v${VERSION}
    SHA512 3b8924f22ae62d58f03ae16b9c485ee35c617aa37d99d94b0ab21e8fd70fa51ef3a10de6f578b51fa3e1dcf37afe484c409c9abb5c6525b5b49a3bafc46c47c7
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINJA_USE_EMBEDDED_JSON=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/inja")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
