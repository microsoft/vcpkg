vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ismrmrd/ismrmrd
    REF "v${VERSION}"
    SHA512 1e91b78f49c6df0e09d7d6e92f21ad26ed68bcb17cce9d5ae6233d567d16d93e4007a5a76c1b0797581bed68b60ec70a886843d355a1dc98b98dd515f0c177e0
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
