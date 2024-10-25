vcpkg_download_distfile(
    CUDA_PATCHES
    URLS "https://github.com/arrayfire/arrayfire/pull/3552/commits/674e7bec90b90467139d32bf633467fe60824617.diff?full_index=1"
    FILENAME "fix-cuda-674e7bec90b90467139d32bf633467fe60824617.patch"
    SHA512 201ba8c46f5eafd5d8dbc78ddc1fb4c24b8d820f034e081b8ff30712705fe059c2850bbb7394d81931620619071559fed0e98b13cc4f985103e354c44a322e78
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO arrayfire/arrayfire
  REF v${VERSION}
  SHA512 d4f63cbb793c64082fb985582472763c08900296c3017f273a91f00d87af38dd60227ac7417fbc98b71c229c2d74b1f261061bf080e5d75f1f38b0efc7b59425
  HEAD_REF master
  PATCHES
    cross-bin2cpp.diff
    fix-miss-header-file.patch # cstdint
    fmt-11.diff                # due to https://github.com/fmtlib/fmt/issues/3447
    "${CUDA_PATCHES}"
)
file(WRITE "${SOURCE_PATH}/CMakeModules/AF_vcpkg_options.cmake" "# Building vcpkg port, not top-level project")
file(COPY_FILE "${CURRENT_INSTALLED_DIR}/include/half.hpp" "${SOURCE_PATH}/extern/half/include/half.hpp")

vcpkg_check_features(
  OUT_FEATURE_OPTIONS options
  FEATURES
    unified AF_BUILD_UNIFIED
    cpu     AF_BUILD_CPU
    cuda    AF_BUILD_CUDA
    opencl  AF_BUILD_OPENCL
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND options "-DAF_COMPUTE_LIBRARY=Intel-MKL")
else()
    list(APPEND options "-DAF_COMPUTE_LIBRARY=FFTW/LAPACK/BLAS")
endif()

if("cpu" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
      list(APPEND options "-DMKL_THREAD_LAYER=Sequential")
    endif()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        list(APPEND options "-DINT_SIZE=8")
        # This seems scary but only selects the MKL interface. 4 = lp; 8 = ilp; Since x64 has ilp as the default use it!
    endif()
endif()

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(WARNING "NOTE: Windows support with static linkage is still experimental.")
endif()

if(VCPKG_CROSSCOMPILING)
    list(APPEND options "-DCROSS_BIN2CPP=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/bin2cpp${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" AF_WITH_STATIC_MKL)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
    -DAF_BUILD_DOCS=OFF
    -DAF_BUILD_EXAMPLES=OFF
    -DAF_BUILD_FORGE=OFF
    -DAF_COMPUTE_LIBRARY=Intel-MKL
    -DAF_INSTALL_BIN_DIR=bin
    -DAF_INSTALL_CMAKE_DIR=share/${PORT}
    -DAF_INSTALL_EXAMPLE_DIR=share/${PORT}/examples
    -DAF_WITH_EXTERNAL_PACKAGES_ONLY=ON
    -DAF_WITH_IMAGEIO=OFF
    -DAF_WITH_STATIC_MKL=${AF_WITH_STATIC_MKL}
    -DBUILD_TESTING=OFF
    ${options}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

if(NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(TOOL_NAMES bin2cpp AUTO_CLEAN)
endif()

# Keeping helloworld for scripts/test_ports/vcpkg-ci-arrayfire.
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/examples/helloworld" "${CURRENT_PACKAGES_DIR}/share/${PORT}/helloworld")
file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/LICENSES"
  "${CURRENT_PACKAGES_DIR}/debug/etc"
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/LICENSES"
  "${CURRENT_PACKAGES_DIR}/etc"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/examples"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYRIGHT.md")
