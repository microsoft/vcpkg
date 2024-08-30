vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fix8mt/conjure_enum
    REF "v${VERSION}"
    SHA512 b9054a62ba10dd7b27b0fa6d2fd6a0c03eaea0f39fc0ba954e12351face02969fccd393278a9e29fa3f8af52b285b16e5ca6d0bc00a05a6ad08d7482bc1c587c
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/fix8/conjure_enum.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
