vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF "v${VERSION}"
    SHA512 cf5f088126947182556c2e21c94df60e36bdf15bca1a3e4022570b8e9804c133cacf80ab79e60d334d7c56d6a80880168adbf30944db9bf746af4deb96924dd7
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

