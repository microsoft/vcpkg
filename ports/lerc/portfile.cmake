vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Esri/lerc
    REF  v2.2
    SHA512 5ddf1e8f0c123d3c1329e980021e25e6ff9b79c96588115e5b48ba7637f0b2bf3ebb2ab6ebf94cfbde45ea1521f14405f669e23f0b74d9ae8f9b2cf80a908215
    HEAD_REF master
    PATCHES
        "install_lib_to_archive_path.patch"
        "enable_static_build.patch"
        "create_package.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

