vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO valgur/velodyne_decoder
    REF "v${VERSION}"
    SHA512 f09dd173cdea6b651a023d799bed7047ee2ac8518446d57e289a6eed9a92ff1ec2644ec49b78bd29ecfebb2046cb89455910bcb476db852a14e42e106b9881ce
    HEAD_REF develop
    PATCHES
        0001-fix-msvc-flags.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALL_THIRD_PARTY=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "velodyne_decoder"
    CONFIG_PATH lib/cmake/velodyne_decoder
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
