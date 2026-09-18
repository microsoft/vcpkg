set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_tools
    REF 2f2196283d4f8789274d862c147e6308ba0b55bf
    SHA512 711e1a7fb239fe854a873d27d92b0192a5fd85d60b8875872dc5321c44156040c3b6c27adcc25eebaf40bbb1d6c712d2ce8104328dc7be344aed0e79c0c2c182
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
