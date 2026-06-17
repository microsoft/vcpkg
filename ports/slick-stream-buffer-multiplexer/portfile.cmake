set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer-multiplexer
    REF "v${VERSION}"
    SHA512 4100f3677f7b4e9930f4f051ea16015facac16f22522ef2a1ad56ae410f4d816e07b66591105354e14f20c14641bbeab6b85eaf036d8bf43843fc70b1e9d0b3b
    HEAD_REF main
    PATCHES
        slick-dependencies-fetching.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_STREAM_BUFFER_MULTIPLEXER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-stream-buffer-multiplexer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
