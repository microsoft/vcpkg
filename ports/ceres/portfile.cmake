vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF 85331393dc0dff09f6fb9903ab0c4bfa3e134b01 #2.2.0
    SHA512 16d3f4f3524b7532f666c0a626f1c678170698119eff3d914ade2e7cc65f25e644c2eabb618cd5805cba0fd4e08d3f64658a9f480934d8aace4089ec42b3d691
    HEAD_REF master
    PATCHES
        0001_cmakelists_fixes.patch
        0004_remove_broken_fake_ba_jac.patch
        0005_link_cuda_static.patch
        0006_fix_cuda_architectures.patch
        0007_support_cuda_13.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindEigen.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindMETIS.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindSuiteSparse.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "cuda"              USE_CUDA
        "eigensparse"       EIGENSPARSE
        "lapack"            LAPACK
        "schur"             SCHUR_SPECIALIZATIONS
        "suitesparse"       SUITESPARSE
)

if(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DMINIGLOG=ON)
endif()

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
endif()

if(VCPKG_TARGET_IS_IOS)
    # Note: CMake uses "OSX" not just for macOS, but also iOS, watchOS and tvOS.
    list(APPEND FEATURE_OPTIONS "-DIOS_DEPLOYMENT_TARGET=${VCPKG_OSX_DEPLOYMENT_TARGET}")
endif()

# Add big object support for MinGW
if(VCPKG_TARGET_IS_MINGW)
    list(APPEND FEATURE_OPTIONS "-DCMAKE_CXX_FLAGS=-Wa,-mbig-obj")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DPROVIDE_UNINSTALL_TARGET=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
        -DVCPKG_LOCK_FIND_PACKAGE_CUDAToolkit=ON
        -DVCPKG_LOCK_FIND_PACKAGE_gflags=OFF  # No direct use except examples+tests
        -DVCPKG_LOCK_FIND_PACKAGE_LAPACK=ON
    MAYBE_UNUSED_VARIABLES
        MSVC_USE_STATIC_CRT
        VCPKG_LOCK_FIND_PACKAGE_CUDAToolkit
        VCPKG_LOCK_FIND_PACKAGE_LAPACK
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Ceres")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
