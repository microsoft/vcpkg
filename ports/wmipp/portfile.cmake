vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sonodima/wmipp
    REF "v${VERSION}"

    SHA512 e52ad6edadcb5b56c941d18e10968f10ea4fbbb0773132c2eb929e83cbf4aa22b72a161f55b358541e27786ff7f967786eb156b7ff519f8d3449d8b5ef2aa727 
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/wmipp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
