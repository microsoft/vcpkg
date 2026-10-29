set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_list
    REF 96cc0e01d82533a05f130a2eef3447ae3e68b0fd
    SHA512 8befc67bd1eda8949dc4e8fbe91b762c400050f368a98b56c58ca0ec4f7ac38a824166b07fd973f802e7e6dafe6a973d8f3c4f33b296775b5aeaf142e4a267f6
    HEAD_REF master
)

# Do not copy "plf_tools.h" and "plf_tools_undef.h" here - they get installed
# via plf-tools to avoid conflicts other ports of the same maintainer
file(COPY "${SOURCE_PATH}/plf_list.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
