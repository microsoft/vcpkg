vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kwallet
    REF "v${VERSION}"
    SHA512 d871776227b126fa191e850959472ab0de9f186ee1d7d48560b20b2021d8d55c25d214a418fdfe72e8be2c6426c1526a54958d5906d56db32e253dea2d76a21c
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_KWALLETD=OFF
        -DBUILD_KSECRETD=OFF
        -DBUILD_KWALLET_QUERY=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_KF6DocTools=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_KF6DocTools
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6wallet CONFIG_PATH lib/cmake/KF6Wallet)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
