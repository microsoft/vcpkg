vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ismrmrd/ismrmrd
    REF "v${VERSION}"
    SHA512 1cf7295c672b84c7ab182bdd57902572b44830e0429bfbf62a57097ee01e086e6a53b23545444ddd741f25ac19195269c2fba65a3222fa1acdc2b90e57e1ecc0
    HEAD_REF master
    PATCHES
        win32_runtime_fix.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hdf5         USE_HDF5_DATASET_SUPPORT
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UTILITIES=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_build() # For some reason the install target doesn't build the library before
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ISMRMRD/)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
