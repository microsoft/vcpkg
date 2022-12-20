vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rootmos/libpquv
    REF ed2fc3b25cf4564d4527f7a1508bb1414cfff271
    SHA512 81f4f0f84b7f2830056d4f992693f221d122471f161ef1453847ee131ebeec4dff46238bd654cf1da27ecfa617ea97a2abe6e8639da9f3fb2f685ab2348c46fb
    HEAD_REF master
    PATCHES
        0001-cmake-files.patch
        0002-includes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-pquv)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "")
