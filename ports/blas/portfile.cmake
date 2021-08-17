SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.netlib.org/blas/blas-3.10.0.tgz"
    FILENAME "blas-3.10.0.tgz"
    SHA512 1f243ce4f7e0974e62c03c49da2741509662e20e82d0ebb73e10a940cff6458739b9dc238125d5e1ae7c179eaba06155bb502327bd58eaf246c29a16e554eeb0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES fix-install.patch
)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        single      BUILD_SINGLE
        double      BUILD_DOUBLE
        complex     BUILD_COMPLEX
        complex16   BUILD_COMPLEX16
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(BUILD_X64 ON)
else()
    set(BUILD_X64 OFF)
endif()

include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      ${FEATURE_OPTIONS}
      ${FORTRAN_CMAKE}
      -DBUILD_INDEX64=${BUILD_X64}
      -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
