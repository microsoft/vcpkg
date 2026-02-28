vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO viskores/viskores
    REF "v${VERSION}"
    SHA512 6b3e048b4af791b6a182b590c1b64835f86c3d4f9e786c9ed06dda1fccb053d03c9ef3334e424e03d1c0e617a849417abdab97c651296cf58724c7e2e37e3660
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
	FEATURES
	cuda Viskores_ENABLE_CUDA
        kokkos Viskores_ENABLE_KOKKOS
        tbb Viskores_ENABLE_TBB
        rendering Viskores_ENABLE_RENDERING
        double     Viskores_USE_DOUBLE_PRECISION
        hdf5       Viskores_ENABLE_HDF5_IO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
	-DViskores_ENABLE_RENDERING=OFF
	-DViskores_ENABLE_DOCUMENTATION=OFF
	-DViskores_ENABLE_EXAMPLES=OFF
	-DViskores_ENABLE_TUTORIALS=ON
	-DViskores_ENABLE_TESTING=OFF
	-DViskores_ENABLE_TESTING_LIBRARY=OFF
	-DViskores_ENABLE_OPENMP=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME viskores-1.1)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
