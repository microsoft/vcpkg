set(MSVC_USE_STATIC_CRT_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        message(FATAL_ERROR "Ceres does not currently support mixing static CRT and dynamic library linkage")
    endif()
    set(MSVC_USE_STATIC_CRT_VALUE ON)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF 1.14.0
    SHA512 6dddddf5bd5834332a69add468578ad527e4d94fe85c9751ddf5fe9ad11a34918bdd9c994c49dd6ffc398333d0ac9752ac89aaef1293e2fe0a55524e303d415d
    HEAD_REF master
    PATCHES
        0001_add_missing_include_path.patch
        0002_cmakelists_fixes.patch
        0003_remove_unnecessary_cmake_modules.patch
        0004_use_glog_target.patch
        0005_fix_exported_ceres_config.patch
)

set(SUITESPARSE OFF)
if("suitesparse" IN_LIST FEATURES)
    set(SUITESPARSE ON)
endif()

set(CXSPARSE OFF)
if("cxsparse" IN_LIST FEATURES)
    set(CXSPARSE ON)
endif()

set(LAPACK OFF)
if("lapack" IN_LIST FEATURES)
    set(LAPACK ON)
endif()

set(EIGENSPARSE OFF)
if("eigensparse" IN_LIST FEATURES)
    set(EIGENSPARSE ON)
endif()

set(GFLAGS OFF)
if("tools" IN_LIST FEATURES)
    set(GFLAGS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DGFLAGS=${GFLAGS}
        -DCXSPARSE=${CXSPARSE}
        -DEIGENSPARSE=${EIGENSPARSE}
        -DLAPACK=${LAPACK}
        -DSUITESPARSE=${SUITESPARSE}
        -DGFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION=ON
        -DGLOG_PREFER_EXPORTED_GLOG_CMAKE_CONFIGURATION=OFF # TheiaSfm doesn't work well with this.
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
)

vcpkg_install_cmake()

if(WIN32)
  vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH "lib${LIB_SUFFIX}/cmake/Ceres")
endif()

vcpkg_copy_pdbs()

# Changes target search path
if(WIN32)
  file(READ ${CURRENT_PACKAGES_DIR}/share/ceres/CeresConfig.cmake CERES_TARGETS)
  string(REPLACE "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n    \${CERES_CURRENT_CONFIG_DIR}/../"
                 "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n    \${CERES_CURRENT_CONFIG_DIR}/../../" CERES_TARGETS "${CERES_TARGETS}")
  file(WRITE ${CURRENT_PACKAGES_DIR}/share/ceres/CeresConfig.cmake "${CERES_TARGETS}")
else()
  file(READ ${CURRENT_PACKAGES_DIR}/share/ceres/CeresConfig.cmake CERES_TARGETS)
  string(REPLACE "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n    \${CERES_CURRENT_CONFIG_DIR}/../../../"
                 "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n    \${CERES_CURRENT_CONFIG_DIR}/../../" CERES_TARGETS "${CERES_TARGETS}")
  file(WRITE ${CURRENT_PACKAGES_DIR}/share/ceres/CeresConfig.cmake "${CERES_TARGETS}")
endif()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright of suitesparse and metis
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ceres)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ceres/LICENSE ${CURRENT_PACKAGES_DIR}/share/ceres/copyright)
