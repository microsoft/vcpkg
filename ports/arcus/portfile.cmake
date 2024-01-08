vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ultimaker/libArcus
    REF ${VERSION}
    SHA512 91a6ca7b8511f33cd152190e6e4c91ac0b82544972686256d09dee6eb5689a3b63de2033fb94676bd2834bc64b942abbaa448e0844b1fa680f9d396eaeff004c
    HEAD_REF main
    PATCHES
        0001-fix-protobuf-deprecated.patch
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
