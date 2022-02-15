#the port uses inside the CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, which is discouraged by vcpkg.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flann-lib/flann
    REF  1d04523268c388dabf1c0865d69e1b638c8c7d9d
    SHA512 61e322222c2daa0b9677095e5ca231cba7c305ce754ad8e659eee350111c1e04351181c3af04e45ab6e5c9edea49c7b9ec6499bb0dbc080b87af36eb11c6ef7c
    HEAD_REF master
    PATCHES
        fix-build-error.patch
        fix-dependency-hdf5.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hdf5    WITH_HDF5
        cuda    BUILD_CUDA_LIB
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOC=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_MATLAB_BINDINGS=OFF
    OPTIONS_DEBUG 
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/flann RENAME copyright)

vcpkg_fixup_pkgconfig()
