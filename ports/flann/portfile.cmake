#the port uses inside the CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, which is discouraged by vcpkg.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flann-lib/flann
    REF  f9caaf609d8b8cb2b7104a85cf59eb92c275a25d
    SHA512 14cd7d3249109ce66c43258f8b9d158efa3b57f654708e76751290eba25e2cb7fc8044a1d882c6b24d0cda1a8b206709acdb5338086ca1f2d60fef35f0fa85be
    HEAD_REF master
    PATCHES
        fix-dependency-hdf5.patch
        fix-dep-lz4.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hdf5    WITH_HDF5
        cuda    BUILD_CUDA_LIB
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   set(LINK_STATIC ON)
else()
   set(LINK_STATIC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOC=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_MATLAB_BINDINGS=OFF
        -DUSE_OPENMP=OFF
        -DCMAKE_BUILD_STATIC_LIBS=${LINK_STATIC}
    OPTIONS_DEBUG 
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()
