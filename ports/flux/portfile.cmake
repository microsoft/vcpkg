vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcbrindle/flux
    REF 43c09af5cc2e89e32b98ddc3507247f593ec2642
    SHA512 542f4a24b9aa5fe631ba17dcd4f4f6743b81a51b21fd36f08dcefbb224bfc3ec9f178bcd9763beb911c3fbbba3be7dbfc3527ca1e89a82851f306d612c5ca1f0
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLUX_BUILD_EXAMPLES=OFF
        -DFLUX_BUILD_TESTS=OFF
)


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flux)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
