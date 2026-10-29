set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_tools
    REF 6460c9d22ba67fe39bb9203ffddc429b04fbeac1
    SHA512 d1854419799ba336db8c4e58695d973988993a43caed797b5282747d5f1b06b8b0c00ab8228163e6915486fad64aaea19c1275a0a86cd01d7b1e49eb6b717b79
    HEAD_REF main
)

file(
    COPY
        "${SOURCE_PATH}/plf_tools.h"
        "${SOURCE_PATH}/plf_tools_undef.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
