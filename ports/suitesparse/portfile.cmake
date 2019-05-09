include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SUITESPARSE_VER SuiteSparse-5.4.0)
set(SUITESPARSEWIN_VER 1.4.0)
set(SUITESPARSEWIN_PATH ${CURRENT_BUILDTREES_DIR}/src/suitesparse-metis-for-windows-${SUITESPARSEWIN_VER})
set(SUITESPARSE_PATH ${SUITESPARSEWIN_PATH}/Suitesparse)

vcpkg_download_distfile(SUITESPARSE
    URLS "http://faculty.cse.tamu.edu/davis/SuiteSparse/${SUITESPARSE_VER}.tar.gz"
    FILENAME "${SUITESPARSE_VER}.tar.gz"
    SHA512 8328bcc2ef5eb03febf91b9c71159f091ff405c1ba7522e53714120fcf857ceab2d2ecf8bf9a2e1fc45e1a934665a341e3a47f954f87b59934f4fce6164775d6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${SUITESPARSE}
    PATCHES
        fix-install-suitesparse.patch
)

vcpkg_from_github(
  OUT_SOURCE_PATH SUITESPARSEWIN_SOURCE_PATH
  REPO jlblancoc/suitesparse-metis-for-windows
  REF ${SUITESPARSEWIN_VER}
  SHA512 2859d534200ab9b76fca1530eae5de2f9328aa867c727dbc83a96c6f16e1f87e70123fb2decbb84531d75dac58b6f0ce7323e48c57aeede324fd9a1f77ba74c6
  HEAD_REF master
)

set(USE_VCPKG_METIS OFF)
if("metis" IN_LIST FEATURES)
    set(USE_VCPKG_METIS ON)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(LIB_EXT a)
    set(LIB_PREFIX lib)
else()
    set(LIB_EXT lib)
    set(LIB_PREFIX)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_METIS=OFF #Disable the option to build metis from source
        -DUSE_VCPKG_METIS=${USE_VCPKG_METIS} #Force using vcpckg metis library
        -DMETIS_SOURCE_DIR=${CURRENT_INSTALLED_DIR}
        -DSUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS=ON
     OPTIONS_DEBUG
        -DSUITESPARSE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
        -DSUITESPARSE_CUSTOM_BLAS_LIB=${CURRENT_INSTALLED_DIR}/debug/lib/${LIB_PREFIX}openblas_d.${LIB_EXT}
        -DSUITESPARSE_CUSTOM_LAPACK_LIB=${CURRENT_INSTALLED_DIR}/debug/lib/${LIB_PREFIX}lapack.${LIB_EXT}
     OPTIONS_RELEASE
        -DSUITESPARSE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
        -DSUITESPARSE_CUSTOM_BLAS_LIB=${CURRENT_INSTALLED_DIR}/lib/${LIB_PREFIX}openblas.${LIB_EXT}
        -DSUITESPARSE_CUSTOM_LAPACK_LIB=${CURRENT_INSTALLED_DIR}/lib/${LIB_PREFIX}lapack.${LIB_EXT}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake")

#clean folders
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright of suitesparse and suitesparse-metis-for-windows
file(COPY ${SUITESPARSE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright)

file(COPY ${SUITESPARSEWIN_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright_suitesparse-metis-for-windows)
