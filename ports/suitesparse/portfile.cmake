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

set(SUITESPARSE_VER SuiteSparse-4.5.5)  #if you change the version, becarefull of changing the SHA512 checksum accordingly
set(METIS_VER metis-5.1.0)
set(SUITESPARSEWIN_PATH ${CURRENT_BUILDTREES_DIR}/src/suitesparse-metis-for-windows-1.3.1)
set(SUITESPARSE_PATH ${SUITESPARSEWIN_PATH}/Suitesparse)
set(METIS_PATH ${SUITESPARSEWIN_PATH}/metis)

#CMake scripts for painless usage of SuiteSparse+METIS from Visual Studio and the rest of Windows/Linux/OSX IDEs supported by CMake 
vcpkg_download_distfile(SUITESPARSEWIN
URLS  "https://github.com/jlblancoc/suitesparse-metis-for-windows/archive/v1.3.1.zip"
FILENAME "suitesparse-metis-for-windows-1.3.1.zip"
SHA512 f8b9377420432f1c0a05bf884fe9e72f1f4eaf7e05663c66a383b5d8ddbd4fbfaa7d433727b4dc3e66b41dbb96b1327d380b68a51a424276465512666e63393d
)
#suitesparse libary
vcpkg_download_distfile(SUITESPARSE
    URLS "http://faculty.cse.tamu.edu/davis/SuiteSparse/${SUITESPARSE_VER}.tar.gz"
    FILENAME "${SUITESPARSE_VER}.tar.gz"
    SHA512 4337c683027efca6c0800815587409db14db7d70df673451e307eb3ece5538815d06d90f3a831fa45071372f70b6f37eaa68fe951f69dbb52a5bfd84d2dc4913
)
#Metis library
vcpkg_download_distfile(METIS
    URLS "http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/${METIS_VER}.tar.gz"
    FILENAME "${METIS_VER}.tar.gz"
    SHA512 deea47749d13bd06fbeaf98a53c6c0b61603ddc17a43dae81d72c8015576f6495fd83c11b0ef68d024879ed5415c14ebdbd87ce49c181bdac680573bea8bdb25
)

vcpkg_extract_source_archive(${SUITESPARSEWIN})

#extract suitesparse and copy into suitesparse folder in suitesparse-metis-for-windows package
vcpkg_extract_source_archive(${SUITESPARSE} ${SUITESPARSEWIN_PATH})

#extract metis and copy into metis folder in suitesparse-metis-for-windows package
vcpkg_extract_source_archive(${METIS})
file(COPY ${CURRENT_BUILDTREES_DIR}/src/${METIS_VER} DESTINATION ${METIS_PATH})


vcpkg_apply_patches(
    SOURCE_PATH ${METIS_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/metis.patch"           
)
vcpkg_apply_patches(
    SOURCE_PATH ${SUITESPARSEWIN_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-install-suitesparse.patch"           
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SUITESPARSEWIN_PATH}
	 PREFER_NINJA # Disable this option if project cannot be built with Ninja
     OPTIONS
	-DBUILD_METIS=ON    
	-DSUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS=ON
	-DSUITESPARSE_CUSTOM_BLAS_LIB=${VCPKG_ROOT_DIR}/packages/openblas_${TARGET_TRIPLET}/lib/openblas.lib
	-DSUITESPARSE_CUSTOM_LAPACK_LIB=${VCPKG_ROOT_DIR}/packages/clapack_${TARGET_TRIPLET}/lib/lapack.lib
	-Dsuitesparse_PKG_DIR=${CURRENT_PACKAGES_DIR}
     #OPTIONS_RELEASE
	 #OPTIONS_DEBUG     
)
vcpkg_install_cmake()


# Handle copyright of suitesparse and metis
file(COPY ${SUITESPARSE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright)
file(COPY ${METIS_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright_metis)


vcpkg_copy_pdbs()