#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiny-dnn/tiny-dnn
    REF 4a59e4cc8799b3a768618cb157a2edc9d0f05b91
    SHA512 408cfec895140d10c9a498ce78da3ad1e11c245a05c05c5cd82ccedd100fbadad7fb02a4e4c2cb924f8d2c35eca31176dd8270927b5d8376946a237066b10795
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)
