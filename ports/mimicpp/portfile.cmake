vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DNKpp/mimicpp
    REF "v${VERSION}"
    SHA512 48e17ed91d14cd466ad7216849363953793ee3a8d2fa2619600c6177eebcb04e6cd458eff7cbc1a589ae31eebfbb3fa862c430a5ef09e8e0dfbe601f540ae0dc
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMIMICPP_BUILD_TESTS=OFF
        -DMIMICPP_BUILD_EXAMPLES=OFF
        -DMIMICPP_CONFIGURE_DOXYGEN=OFF
        -DMIMICPP_ENABLE_AMALGAMATE_HEADERS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/mimipp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
