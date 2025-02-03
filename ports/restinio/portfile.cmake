vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF "v.${VERSION}"
    SHA512 942bb2b4b7591ae3b336742142bf1df3dc43ae3bfa84e26991bd922670997fe7099438a40607353a733e0a4ba38a33da7bf1ad8e382a284c04ada09a2f149fd8
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

