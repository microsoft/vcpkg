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
    REF f68321e7de8929fbcdb95dd42877531e64f72f66 #2.1.0
    SHA512 67bbd8a9385a40fe69d118fbc84da0fcc9aa1fbe14dd52f5403ed09686504213a1d931e95a1a0148d293b27ab5ce7c1d618fbf2e8fed95f2bbafab851a1ef449
    HEAD_REF master
    PATCHES
        0001_cmakelists_fixes.patch
        0002_use_glog_target.patch
        0003_fix_exported_ceres_config.patch
        find-package-required.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindCXSparse.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindEigen.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindSuiteSparse.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindMETIS.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "suitesparse"       SUITESPARSE
        "cxsparse"          CXSPARSE
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
        -DPROVIDE_UNINSTALL_TARGET=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
        -DLIB_SUFFIX=${LIB_SUFFIX}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib${LIB_SUFFIX}/cmake/Ceres")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
