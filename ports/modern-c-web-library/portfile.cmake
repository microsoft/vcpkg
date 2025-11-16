vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kamrankhan78694/modern-c-web-library
    REF v0.3.0
    SHA512 f57556aaed8c1a00c9e42f6db5a90f4a94faaea71f8815a288ae6aa13956819170c72d849e021591be4d23e4f986d2ecffdd72485795a851e1a4ce94bcf86358
)

# Configure build: disable tests/examples for packaging
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_build()

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()
# Remove debug include directory to satisfy policy (headers identical)
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
