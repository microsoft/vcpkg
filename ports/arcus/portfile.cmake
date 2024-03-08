vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ultimaker/libArcus
    REF "${VERSION}"
    SHA512 8106bbcd595921d56e39bf694fbee43c6146a9c661edf9fb1fe271bbcf199a202e399cfbda5b83711c9daad1c55d8242ba23ce4fb52c416ddd862fb6de2bcab3
    HEAD_REF master
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

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
