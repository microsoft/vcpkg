vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-lambda-cpp
    REF "v${VERSION}"
    SHA512 842bada21427c9c85442b8a33228bae7b347214418fcd0681154f1bd384633217d724cab53cddf372a59dfa5de01cca59118a316b0fd58fe9f2403b3b62163f6
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME aws-lambda-runtime CONFIG_PATH lib/aws-lambda-runtime/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/aws-lambda-runtime")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/aws-lambda-runtime")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
