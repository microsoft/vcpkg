vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DNKpp/mimicpp
    REF "v${VERSION}"
    SHA512 b888fd71726db223d0cca1daaeea149870e0bf9adeb61c37f91925e00fda81744d686ec81b465ae9066ba9145a43d9fb6bb7af24c5c4d4da41cbc1bd66ab8dd6
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

vcpkg_cmake_config_fixup(CONFIG_PATH cmake/mimicpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
