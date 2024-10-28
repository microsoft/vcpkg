vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF "v.${VERSION}"
    SHA512 ac47e83b2fdcbf5a42b3b5af8f5db7f400baa18515c6a042ee6aacc77df03aa1a90f14a57a1127ce2472bf72dc568160ff3c07aaddd4235910b7b831bcfcf569
)

set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dev"
    OPTIONS
        -DRESTINIO_INSTALL=ON
        -DRESTINIO_TEST=OFF
        -DRESTINIO_SAMPLE=OFF
        -DRESTINIO_BENCHMARK=OFF
        -DRESTINIO_WITH_SOBJECTIZER=OFF
        -DRESTINIO_ASIO_SOURCE=standalone
        -DRESTINIO_DEP_STANDALONE_ASIO=find
        -DRESTINIO_DEP_LLHTTP=find
        -DRESTINIO_DEP_FMT=find
        -DRESTINIO_DEP_EXPECTED_LITE=find
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

