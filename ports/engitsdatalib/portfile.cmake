vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO enGits/enGitsDataLib
    REF v1.0.0
    SHA512 7dc9c240b45bb3a768ea910c1a29c5aa885debd636b2aff49211ee1f4cef6ce2bc4803775e8afe5fc16c4ae8276cbcd3a0a56325da1930a395db57b1fa37dccf
    HEAD_REF master
    PATCHES
        use-system-doctest.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" EDL_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCREATE_STATIC_LIBRARY=${EDL_BUILD_STATIC}"
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME enGitsDataLib
    CONFIG_PATH lib/cmake/enGitsDataLib
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
