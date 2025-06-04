vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IfcOpenShell/IfcOpenShell
    REF "v${VERSION}"
    SHA512 ec94ac1557f47331312ac2f3fe7b9b88bd04d7c4f7477bd0283e52e57a34e434ca636ff2fe72b028f92cdf1d5391cd5aba8f62216038c57f1d099f61dad6ff3a
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-boost.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "vld" USE_VLD
        "python" BUILD_PACKAGE
        "hdf5" HDF5_SUPPORT
        "usd" USD_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMINIMAL_BUILD=ON
        -DSCHEMA_VERSIONS=2x3;4;4x3;4x3_add2
        -DMSVC_PARALLEL_BUILD=OFF # handled by vcpkg
        -DENABLE_BUILD_OPTIMIZATIONS=OFF # handled by vcpkg
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_IFCGEOM=OFF
        -DBUILD_CONVERT=OFF
        -DBUILD_GEOMSERVER=OFF
        -DBUILD_IFCPYTHON=OFF
        -DBUILD_QTVIEWER=OFF
        -DGLTF_SUPPORT=OFF
        -DCOLLADA_SUPPORT=OFF
        -DBUILD_IFCMAX=OFF
        -DUSE_MMAP=OFF
        -DWASM_BUILD=OFF
        -DUSERSPACE_PYTHON_PREFIX=OFF
        -DADD_COMMIT_SHA=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
