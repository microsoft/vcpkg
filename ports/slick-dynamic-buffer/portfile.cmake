set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-dynamic-buffer
    REF "v${VERSION}"
    SHA512 0467d934857e7eb159998adcadad6210d4e483ca974d8d75d928eb38e11312c35f364115f159a5c8f7962e24aa2536be855e97de72bf15350e915135861d7e47
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_DYNAMIC_BUFFER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-dynamic-buffer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
