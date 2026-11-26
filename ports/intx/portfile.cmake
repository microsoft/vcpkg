set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chfast/intx
    REF "v${VERSION}"
    SHA512 818a76ab24afb2bb1b82a4c3c2ab59a660ee6170511d11cb935dc2ec1c77f924704e844b4df1a49daf710a2814509b71e4f4ae26214119fbc9105098678cccbb
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINTX_BENCHMARKING=OFF
        -DINTX_FUZZING=OFF
        -DINTX_INSTALL=ON
        -DINTX_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/intx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
