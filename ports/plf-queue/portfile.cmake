set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_queue
    REF 52486f9bb966a54a7567dca77e363dbbdddb47f8
    SHA512 4fc03b026da10a04e186ca9c1b16eea61bf6df7b7ddd684d0781924ddc225350f8c40024e26fc729f26fd9cbec93ce58d7ac7ae6c4cf55e266477f6f3f52dac8
    HEAD_REF main
)

# Do not copy "plf_tools.h" and "plf_tools_undef.h" here - they get installed
# via plf-tools to avoid conflicts other ports of the same maintainer
file(COPY "${SOURCE_PATH}/plf_queue.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
)
