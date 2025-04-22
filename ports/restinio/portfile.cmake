vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF "v${VERSION}"
    SHA512 2ce55df175d7a92601c36e0a765366207853f9e5886d25765f56443a79feeefa56e61add11024f9595b8094e303574df853d6a10b8fbf0c3aa31729668c67471
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

