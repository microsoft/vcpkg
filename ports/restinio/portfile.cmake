vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF "v.${VERSION}"
    SHA512 457e9eaeb310f731ef360432df6952c3b5a93ae82fef8cc4be62efa02d0cb75e2dda389ab131ad8fe1706ea097c0436f1ecc36feeffb1ed3b77c1a0afb629df7
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

