vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sourcemeta/blaze
    REF 51a6158e5094c7881a68c0e9411023f1b1822a9f
    SHA512 69d85f0eac77fdc73a0689df209c3241ea311a9599ee89bff62abbfc24c2a23848f8ea761e0b4efadd976024601f3b2a7c0ebb6ed696a16bfd976aabf6da2daf
    HEAD_REF master
    PATCHES
        use_vcpkg_libs.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/core/vendor/boost-regex")
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/core/vendor/uriparser")
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/core/vendor/yaml")
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/vendorpull")
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/jsonschema-test-suite")
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/core/vendor/googletest")
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/core/vendor/googlebenchmark")




vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME blaze CONFIG_PATH "lib/cmake/blaze")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
