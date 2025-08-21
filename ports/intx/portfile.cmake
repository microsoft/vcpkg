vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chfast/intx
    REF "v${VERSION}"
    SHA512 e1126f79cda6455aae4c04bed8deb91be4f47a6ab545a50b840f9f4df5e2d0c36be4e35e5576767b971903522ea8e37490db78efe08a85dbaadf2a396196fba6
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
