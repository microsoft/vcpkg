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
    REF 2.0.0
    SHA512 6379666ef57af4ea85026644fa21365ce18fbaa12d50bd452bcdae0743a7b013effdd42c961e90c31815991bf315bd6904553dcc1a382ff5ed8c7abe9edf9a6c
    HEAD_REF master
    PATCHES
        0001_cmakelists_fixes.patch
        0002_use_glog_target.patch
        0003_fix_exported_ceres_config.patch
        0004_fix_lib_path_linux.patch
        find-package-required.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindCXSparse.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindEigen.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindSuiteSparse.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "suitesparse"       SUITESPARSE
        "cxsparse"          CXSPARSE
        "lapack"            LAPACK
        "eigensparse"       EIGENSPARSE
        "tools"             GFLAGS
)

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

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
  vcpkg_cmake_config_fixup(CONFIG_PATH "lib${LIB_SUFFIX}/cmake/Ceres")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
