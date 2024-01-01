vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaozhuai/imageinfo
    REF eb2f4a0727d425ecfe2debd3475bea1f570b1a8d # committed on 2023-12-25
    SHA512 1f03ff2dbe49d27e757b66c57c28e8a53ddbe372b20bb3f5891d1644dd885a851f55fb40c42637ca3528023b37e1b980b11cbe64fa5484f12a2c462052ae247a
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIMAGEINFO_BUILD_TOOL=OFF
        -DIMAGEINFO_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
