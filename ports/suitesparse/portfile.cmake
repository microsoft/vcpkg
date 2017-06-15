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

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(SUITESPARSE_VER SuiteSparse-4.5.5)  #if you change the version, becarefull of changing the SHA512 checksum accordingly
set(SUITESPARSEWIN_PATH ${CURRENT_BUILDTREES_DIR}/src/suitesparse-metis-for-windows-1.3.1)
set(SUITESPARSE_PATH ${SUITESPARSEWIN_PATH}/Suitesparse)

#download suitesparse libary
vcpkg_download_distfile(SUITESPARSE
    URLS "http://faculty.cse.tamu.edu/davis/SuiteSparse/${SUITESPARSE_VER}.tar.gz"
    FILENAME "${SUITESPARSE_VER}.tar.gz"
    SHA512 4337c683027efca6c0800815587409db14db7d70df673451e307eb3ece5538815d06d90f3a831fa45071372f70b6f37eaa68fe951f69dbb52a5bfd84d2dc4913
)

#download suitesparse-metis-for-windows scripts, suitesparse does not have CMake build system, jlblancoc has made one for it
vcpkg_download_distfile(SUITESPARSEWIN
    URLS  "https://github.com/jlblancoc/suitesparse-metis-for-windows/archive/v1.3.1.zip"
    FILENAME "suitesparse-metis-for-windows-1.3.1.zip"
    SHA512 f8b9377420432f1c0a05bf884fe9e72f1f4eaf7e05663c66a383b5d8ddbd4fbfaa7d433727b4dc3e66b41dbb96b1327d380b68a51a424276465512666e63393d
)

#extract suitesparse-metis-for-windows first and merge with suitesparse library
vcpkg_extract_source_archive(${SUITESPARSEWIN})
vcpkg_extract_source_archive(${SUITESPARSE} ${SUITESPARSEWIN_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SUITESPARSEWIN_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-install-suitesparse.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SUITESPARSEWIN_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_METIS=OFF #Disable the option to build metis from source
        -DUSE_VCPKG_METIS=ON #Force using vcpckg metis library
        -DMETIS_SOURCE_DIR=${CURRENT_INSTALLED_DIR}
        -DLIB_POSTFIX=
        -DSUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS=ON
        -DSUITESPARSE_CUSTOM_BLAS_LIB=${CURRENT_INSTALLED_DIR}/lib/openblas.lib
        -DSUITESPARSE_CUSTOM_LAPACK_LIB=${CURRENT_INSTALLED_DIR}/lib/lapack.lib
     OPTIONS_DEBUG
        -DSUITESPARSE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
     OPTIONS_RELEASE
        -DSUITESPARSE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/suitesparse/)

file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/SuiteSparse-config.cmake ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparse-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/SuiteSparse-config-release.cmake ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparse-config-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/cmake/SuiteSparse-config-debug.cmake ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparse-config-debug.cmake)

file(RENAME ${CURRENT_PACKAGES_DIR}/UseSuiteSparse.cmake ${CURRENT_PACKAGES_DIR}/share/suitesparse/UseSuiteSparse.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/SuiteSparseConfig.cmake ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparseConfig.cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/UseSuiteSparse.cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/SuiteSparseConfig.cmake)

# Update paths in SuiteSparseConfig.cmake
file(READ ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparseConfig.cmake _contents)
string(REPLACE "set(SuiteSparse_LIB_POSTFIX \"64\")" "set(SuiteSparse_LIB_POSTFIX \"\")" _contents "${_contents}")
string(REPLACE "\#\# do nothing, it's OK" "include(${USE_SuiteSparse})" _contents "${_contents}")

file(WRITE ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparseConfig.cmake "${_contents}")

# Update paths in SuiteSparse-config.cmake
file(READ ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparse-config.cmake _contents)
string(REPLACE "get_filename_component(_IMPORT_PREFIX \"${_IMPORT_PREFIX}\" PATH)"
    "get_filename_component(_IMPORT_PREFIX \"${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"${_IMPORT_PREFIX}\" PATH)" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparse-config.cmake "${_contents}")

# Update paths in SuiteSparse-config-debug.cmake
file(READ ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparse-config-debug.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/debug/lib/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/suitesparse/SuiteSparse-config-debug.cmake "${_contents}")

#clean folders
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright of suitesparse and suitesparse-metis-for-windows
file(COPY ${SUITESPARSE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright)

file(COPY ${SUITESPARSEWIN_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright_suitesparse-metis-for-windows)
