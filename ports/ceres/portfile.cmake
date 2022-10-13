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
    REF 9893c534c0f748277542479e6771c46490d8b6db #2.1.0
    SHA512 a1da1297fc28c84e45fa218e48eba8ff3ad53c8eb4eb1a98858b3343592e23ede5770c5880460a30c46707afdcb1e740b79afa9150f5f952089f1189627fa4e9
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
        "lapack"            LAPACK
        "eigensparse"       EIGENSPARSE
        "tools"             GFLAGS
        "cuda"              USE_CUDA
)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DMINIGLOG=ON)
endif()

foreach (FEATURE ${FEATURE_OPTIONS})
    message(STATUS "${FEATURE}")
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
