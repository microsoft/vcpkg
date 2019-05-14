include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SUITESPARSE_VER 5.4.0)
set(SUITESPARSEWIN_VER 1.4.0)

vcpkg_download_distfile(SUITESPARSE
    URLS "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-${SUITESPARSE_VER}.tar.gz"
    FILENAME "SuiteSparse-${SUITESPARSE_VER}.tar.gz"
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
  REF v${SUITESPARSEWIN_VER}
  SHA512 35a2563d6e33ebe8157f8d023167abd8d2512e2a627b8dbea798c59afefc56b8f01c7d10553529b03a7b4759e200ca82bb26ebce5cefce6983ffb057a8622162
  HEAD_REF master
)

# Copy suitesparse sources.
message(STATUS "Copying SuiteSparse source files...")
# Should probably remove everything but CMakeLists.txt files?
file(GLOB SUITESPARSE_SOURCE_FILES ${SOURCE_PATH}/*)
foreach(SOURCE_FILE ${SUITESPARSE_SOURCE_FILES})
    file(COPY ${SOURCE_FILE} DESTINATION "${SUITESPARSEWIN_SOURCE_PATH}/SuiteSparse")
endforeach()
message(STATUS "Copying SuiteSparse source files... done")

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
    SOURCE_PATH ${SUITESPARSEWIN_SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_METIS=OFF #Disable the option to build metis from source
        -DUSE_VCPKG_METIS=${USE_VCPKG_METIS} #Force using vcpckg metis library
        -DMETIS_SOURCE_DIR="${CURRENT_INSTALLED_DIR}"
        -DSUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS=ON
     OPTIONS_DEBUG
        -DSUITESPARSE_INSTALL_PREFIX="${CURRENT_PACKAGES_DIR}/debug"
        -DSUITESPARSE_CUSTOM_BLAS_LIB="${CURRENT_INSTALLED_DIR}/debug/lib/${LIB_PREFIX}openblas_d.${LIB_EXT}"
        -DSUITESPARSE_CUSTOM_LAPACK_LIB="${CURRENT_INSTALLED_DIR}/debug/lib/${LIB_PREFIX}lapack.${LIB_EXT}"
     OPTIONS_RELEASE
        -DSUITESPARSE_INSTALL_PREFIX="${CURRENT_PACKAGES_DIR}"
        -DSUITESPARSE_CUSTOM_BLAS_LIB="${CURRENT_INSTALLED_DIR}/lib/${LIB_PREFIX}openblas.${LIB_EXT}"
        -DSUITESPARSE_CUSTOM_LAPACK_LIB="${CURRENT_INSTALLED_DIR}/lib/${LIB_PREFIX}lapack.${LIB_EXT}"
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/suitesparse-${SUITESPARSE_VER}" TARGET_PATH "share/suitesparse")

#clean folders
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright of suitesparse and suitesparse-metis-for-windows
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright)

file(COPY ${SUITESPARSEWIN_SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/suitesparse)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/suitesparse/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/suitesparse/copyright_suitesparse-metis-for-windows)
