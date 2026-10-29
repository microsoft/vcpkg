set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_stack
    REF 62393b327c81e92f9ffe57c15eedd03a1cb02c90
    SHA512 2818e576a74797885b5e5b9f7e482208075d5a44ceb8ee54f469814d4545994b9b996af377007d12d014e4b584c3a3032ef9706b14c5dbe7abe88ab23ac78d98
    HEAD_REF master
)

# Do not copy "plf_tools.h" and "plf_tools_undef.h" here - they get installed
# via plf-tools to avoid conflicts other ports of the same maintainer
file(COPY "${SOURCE_PATH}/plf_stack.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
