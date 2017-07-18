# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "Ceres does not currently support static CRT linkage")
endif()

include(vcpkg_common_functions)

set(VCPKG_PLATFORM_TOOLSET "v140") # Force VS2015 because VS2017 compiler return internal error
# eigen3\eigen\src\core\redux.h(237): fatal error C1001: An internal error has occurred in the compiler. [internal\ceres\ceres.vcxproj]

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF 1.12.0
    SHA512 4b4cba5627fbd80a626e8a31d9f561d6cee1c8345970304e4b5b163a9dcadc6d636257d1046ecede00781a11229ef671ee89c3e7e6baf15f49f63f36e6a2ebe1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DCXSPARSE=ON
        -DEIGENSPARSE=ON
        -DSUITESPARSE=ON
        -DBLAS_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/openblas.lib
        -DCXSPARSE_INCLUDE_DIR=${SUITESPARSE_INCLUDE_DIR}
        -DCXSPARSE_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/libcxsparse.lib
        -DEIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
        -DGFLAGS_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DGFLAGS_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/gflags.lib
        -DGLOG_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DGLOG_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/glog.lib
        -DLAPACK_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/lapack.lib
        -DMETIS_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/metis.lib
        -DSUITESPARSE_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/suitesparse
    OPTIONS_RELEASE
        -DSUITESPARSE_LIBRARY_DIR_HINTS=${CURRENT_INSTALLED_DIR}/lib
    OPTIONS_DEBUG
        -DSUITESPARSEQR_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/libspqrd.lib
        -DSUITESPARSE_LIBRARY_DIR_HINTS=${CURRENT_INSTALLED_DIR}/debug/lib
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")

file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/CeresConfig.cmake CERES_MODULE)
string(REPLACE "\${CERES_CURRENT_CONFIG_DIR}/../" "\${CERES_CURRENT_CONFIG_DIR}/../../" CERES_MODULE "${CERES_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/CeresConfig.cmake "${CERES_MODULE}")

vcpkg_copy_pdbs()

#clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
# file(REMOVE ${CURRENT_PACKAGES_DIR}/share/ceres/FindEigen.cmake)
# file(REMOVE ${CURRENT_PACKAGES_DIR}/share/ceres/FindGflags.cmake)
# file(REMOVE ${CURRENT_PACKAGES_DIR}/share/ceres/FindGlog.cmake)

# Handle copyright of suitesparse and metis
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ceres)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ceres/LICENSE ${CURRENT_PACKAGES_DIR}/share/ceres/copyright)
