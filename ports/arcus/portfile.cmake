vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ultimaker/libArcus
    REF ${VERSION}
    SHA512 452c541360d74a8f58ab1b20df59efd36756812a9ecd09804ba16877956fb240d367bd968271a9c010496598ef0b459f62aa287553d4ba3fdb4cd2742c25553f
    HEAD_REF main
    PATCHES
        0001-fix-protobuf-deprecated.patch
        0002-protobuf-version.patch
        0003-cstdint.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_PYTHON=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC=${ENABLE_STATIC}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME Arcus CONFIG_PATH lib/cmake/Arcus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
