vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-lambda-cpp
    REF "v${VERSION}"
    SHA512 846e288d60b7d73d502070e0367fa51fac9bfdbcab919832d6214010a70932bb79376351ae58e150aa45dd79bbe230f3813dbb5b05caf87044a9eab913551a5f
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
