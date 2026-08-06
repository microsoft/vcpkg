vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Viskores/viskores
    REF "v${VERSION}"
    SHA512 4ec30e96e8f61161255145aad44e986fe34d4ffc3268600d4e54ab4d0a583eaf3ef499d26ae00442b1204c4b202c741b1720438d00f3dc42d05119020a86571c
    HEAD_REF master
    PATCHES
        external-fmt.diff
        no-abs-path.diff
        cuda-backports.diff
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/viskores/thirdparty/diy/viskoresdiy/include/viskoresdiy/thirdparty/fmt"
    # Vendored dependencies, as before in vtk-m.
    # TODO: Should be replaced in the future with VCPKG internal versions
    #[[ "${SOURCE_PATH}/viskores/thirdparty/diy" ]]
    #[[ "${SOURCE_PATH}/viskores/thirdparty/lcl" ]]
    #[[ namespace viskores:  "${SOURCE_PATH}/viskores/thirdparty/lodepng" ]]
    #[[ anonymous namespace: q"${SOURCE_PATH}/viskores/thirdparty/loguru" ]]
    #[[ namespace viskores:  "${SOURCE_PATH}/viskores/thirdparty/optionparser" ]]
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda    Viskores_ENABLE_CUDA
        double  Viskores_USE_DOUBLE_PRECISION
        hdf5    Viskores_ENABLE_HDF5_IO
        omp     Viskores_ENABLE_OPENMP
        tbb     Viskores_ENABLE_TBB
        mpi     Viskores_ENABLE_MPI
)

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        -DCMAKE_CUDA_ARCHITECTURES=all-major # override with VCPKG_CMAKE_CONFIGURE_OPTIONS
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DViskores_ENABLE_CPACK=OFF
        -DViskores_ENABLE_DEVELOPER_FLAGS=OFF
        -DViskores_INSTALL_CONFIG_DIR=share/${PORT}
        -DViskores_INSTALL_SHARE_DIR=share/${PORT}
        -DViskores_NO_INSTALL_README_LICENSE=ON
        -DViskores_USE_DEFAULT_TYPES_FOR_VTK=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
