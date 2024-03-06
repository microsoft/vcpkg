vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Atliac/minitest
    REF v1.0.0
    SHA512 6683a1f94ec1832653e76248c00d332c14fda1efa1d68f92d03b1187cde531a9c65acf0a613839be8a307b1241834177699f461b8b3da03146f5acae79045a52
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME minitest)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")