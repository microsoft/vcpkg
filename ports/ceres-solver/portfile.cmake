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

include(vcpkg_common_functions)

set (CERES_VER 1.12.0) #update SHA512 checksum w.r.t to verison
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ceres-solver-${CERES_VER})

vcpkg_download_distfile(ARCHIVE
URLS  "https://github.com/ceres-solver/ceres-solver/archive/${CERES_VER}.zip"
FILENAME "ceres-solver-${CERES_VER}.zip"
SHA512 cbd476e4be89cad3c3366cd2396be46a49e8672932219d48fcd54f2eef8e86ee7fd9a824aa9743d13324b3ea9ba90501ede0297713a4d5844be75ce95418ecc1
)

vcpkg_extract_source_archive(${ARCHIVE})


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	#PREFER_NINJA # Disable this option if project cannot be built with Ninja
     
	 OPTIONS	 
	-DEXPORT_BUILD_DIR=ON
	-DBUILD_EXAMPLES=OFF
	-DBUILD_TESTING=OFF	
	-DEIGENSPARSE=ON
	-DSUITESPARSE=ON
	-DCXSPARSE=ON
    #-DBUILD_SHARED_LIBS=OFF	
	-DCXSPARSE_INCLUDE_DIR=${SUITESPARSE_INCLUDE_DIR}
	-DCXSPARSE_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/libcxsparse.lib
	-DSUITESPARSE_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/suitesparse	
	-DEIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
	-DLAPACK_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/lapack.lib
	-DBLAS_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/openblas.lib	
	-DMETIS_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/metis.lib 
	-DGFLAGS_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include	
	-DGFLAGS_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/gflags.lib
	-DGLOG_INCLUDE_DIR=${PACKAGES_INCLUDE_DIR} 
	-DGLOG_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/glog.lib 	
	
	OPTIONS_RELEASE	 	
	-DSUITESPARSE_LIBRARY_DIR_HINTS=${CURRENT_INSTALLED_DIR}/lib	
	
	OPTIONS_DEBUG
    -DSUITESPARSEQR_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/libspqrd.lib
	-DSUITESPARSE_LIBRARY_DIR_HINTS=${CURRENT_INSTALLED_DIR}/debug/lib
    
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

#clean 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/CMake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/CMake)

# Handle copyright of suitesparse and metis
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ceres-solver)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ceres-solver/LICENSE ${CURRENT_PACKAGES_DIR}/share/ceres-solver/copyright)


