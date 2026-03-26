set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF "${VERSION}"
    SHA512 9d7371b9ad503505b3558bc8410ceb171a3a9ddd74eb2ca7869448d5fdb62f915b75afb5ff0b54273c80a0bc06d613d22c6c1c64ce297a4eee06c490feaf3b4e
    HEAD_REF master
    PATCHES
        dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp     USE_OPENMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ensmallen)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
