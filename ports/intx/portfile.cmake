vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chfast/intx
    REF "v${VERSION}"
    SHA512 f8b86f53052577965bac480ac6b222aee29ec005e151e596139c7e98e1410c8f9ed27beffa23e58307fa96815af2af9b8dcfbf076d9ea259f609d7d3784f9896
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DINTX_INSTALL=ON
    -DINTX_TESTING=OFF
    -DINTX_BENCHMARKING=OFF
    -DINtX_FUZZING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME intx CONFIG_PATH lib/cmake/intx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
