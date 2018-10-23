include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(SUITESPARSE_VER SuiteSparse-5.1.2)  #if you change the version, becarefull of changing the SHA512 checksum accordingly
set(SUITESPARSEWIN_VER 1.4.0)
set(SUITESPARSEWIN_PATH ${CURRENT_BUILDTREES_DIR}/src/suitesparse-metis-for-windows-${SUITESPARSEWIN_VER})
set(SUITESPARSE_PATH ${SUITESPARSEWIN_PATH}/Suitesparse)

#download suitesparse libary
vcpkg_download_distfile(SUITESPARSE
    URLS "http://faculty.cse.tamu.edu/davis/SuiteSparse/${SUITESPARSE_VER}.tar.gz"
    FILENAME "${SUITESPARSE_VER}.tar.gz"
    SHA512 38c7f9847cf161390f73de39ed3d9fd07f7bcec2d6d4e6f141af6a015826215843db9f2e16ca255eeb233c593ffc19ffa04816aa5b6ba200b55b9472ac33ba85
)

#download suitesparse-metis-for-windows scripts, suitesparse does not have CMake build system, jlblancoc has made one for it
vcpkg_download_distfile(SUITESPARSEWIN
    URLS  "https://github.com/jlblancoc/suitesparse-metis-for-windows/archive/v${SUITESPARSEWIN_VER}.zip"
    FILENAME "suitesparse-metis-for-windows-${SUITESPARSEWIN_VER}.zip"
    SHA512 2859d534200ab9b76fca1530eae5de2f9328aa867c727dbc83a96c6f16e1f87e70123fb2decbb84531d75dac58b6f0ce7323e48c57aeede324fd9a1f77ba74c6
)

#extract suitesparse-metis-for-windows first and merge with suitesparse library
vcpkg_extract_source_archive(${SUITESPARSEWIN})
vcpkg_extract_source_archive(${SUITESPARSE} ${SUITESPARSEWIN_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SUITESPARSEWIN_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-install-suitesparse.patch"
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/remove-debug-postfix.patch"
)

set(USE_VCPKG_METIS OFF)
if("metis" IN_LIST FEATURES)
    set(USE_VCPKG_METIS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SUITESPARSEWIN_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_METIS=OFF #Disable the option to build metis from source
        -DUSE_VCPKG_METIS=${USE_VCPKG_METIS} #Force using vcpckg metis library
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

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake")

#clean folders
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright of suitesparse and suitesparse-metis-for-windows
file(COPY ${SUITESPARSE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright)

file(COPY ${SUITESPARSEWIN_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright_suitesparse-metis-for-windows)
