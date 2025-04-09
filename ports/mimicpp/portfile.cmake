vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DNKpp/mimicpp
    REF "v${VERSION}"
    SHA512 facdf604ce481d291b7f265c7c5dbbb348a8623cf8ee1bb873b70988c8e7d3b0b170fd81f1bc297c28ba6ee09510b50a0f790c5473d6a9c1ad9633304f8c0124
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
