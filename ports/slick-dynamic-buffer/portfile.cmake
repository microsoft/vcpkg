set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-dynamic-buffer
    REF "v${VERSION}"
    SHA512 28a29f9279317e28a0eaec41968cf521ebabef5cc995e07f796be8205b2f9648d3a73ca0f103003d0dfb440ba35b17bc78622e6012bd36e635fab8479d6b4463
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_DYNAMIC_BUFFER_TESTS=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_slick-stream-buffer=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-dynamic-buffer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
