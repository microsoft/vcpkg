set(MSVC_USE_STATIC_CRT_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        message(FATAL_ERROR "Ceres does not support mixing static CRT and dynamic library linkage")
    endif()
    set(MSVC_USE_STATIC_CRT_VALUE ON)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF 85331393dc0dff09f6fb9903ab0c4bfa3e134b01 #2.2.0
    SHA512 16d3f4f3524b7532f666c0a626f1c678170698119eff3d914ade2e7cc65f25e644c2eabb618cd5805cba0fd4e08d3f64658a9f480934d8aace4089ec42b3d691
    HEAD_REF master
    PATCHES
        0001_cmakelists_fixes.patch
        0002_use_glog_target.patch
        0003_fix_exported_ceres_config.patch
        0004_remove_broken_fake_ba_jac.patch
        0005_find_package_required.patch
        0006_use_official_suitesparse_config.patch
        0007_use_metis_config.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindEigen.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindMETIS.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindSuiteSparse.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "schur"             SCHUR_SPECIALIZATIONS
        "suitesparse"       SUITESPARSE
        "lapack"            LAPACK
        "eigensparse"       EIGENSPARSE
        "tools"             GFLAGS
        "cuda"              CUDA
)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DMINIGLOG=ON)
endif()

foreach (FEATURE ${FEATURE_OPTIONS})
    message(STATUS "${FEATURE}")
endforeach()

set(USE_CUDA OFF)
if("cuda" IN_LIST FEATURES)
    set(USE_CUDA ON)
endif()

set(TARGET_OPTIONS )
if(VCPKG_TARGET_IS_IOS)
    # Note: CMake uses "OSX" not just for macOS, but also iOS, watchOS and tvOS.
    list(APPEND TARGET_OPTIONS "-DIOS_DEPLOYMENT_TARGET=${VCPKG_OSX_DEPLOYMENT_TARGET}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${TARGET_OPTIONS}
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARKS=OFF
        -DUSE_CUDA=${USE_CUDA}
        -DPROVIDE_UNINSTALL_TARGET=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
    MAYBE_UNUSED_VARIABLES
        CUDA
        MSVC_USE_STATIC_CRT
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib${LIB_SUFFIX}/cmake/Ceres")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
