# The upstream MUMPS distribution ships a bespoke, non-CMake build system.
# scivision/mumps is the CMake build system referenced by upstream; it downloads
# the MUMPS sources itself, so vcpkg pre-downloads them and points FetchContent
# at the extracted tree to keep the build offline and hash-verified.
set(MUMPS_CMAKE_REF "v5.9.1.1")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO scivision/mumps
    REF "${MUMPS_CMAKE_REF}"
    SHA512 eb23ba6fec795a02de40353556a93a5be41d1774517f1d12e9a12c8b543a13b93360eb97728550df4d2d3e41dd51a9b0278ae88ffc50cf378155a4842bd18403
    HEAD_REF main
    PATCHES
        install-mpiseq-headers-in-subdir.patch
        use-vcpkg-lapack.patch
        export-fortran-runtime.patch
        link-blas-explicitly.patch
        unofficial-mumps-solver-pkgconfig.patch
        unofficial-cmake-exports.patch
)

# Use vcpkg's LAPACK abstraction (the `lapack` port and its cmake wrapper) rather
# than the harness's bundled FindLAPACK, which shadows it via CMAKE_MODULE_PATH
# and searches system paths instead of the vcpkg installed tree.
file(REMOVE "${SOURCE_PATH}/cmake/FindLAPACK.cmake")

vcpkg_download_distfile(MUMPS_ARCHIVE
    URLS "https://mumps-solver.org/MUMPS_${VERSION}.tar.gz"
    FILENAME "MUMPS_${VERSION}.tar.gz"
    SHA512 1984b1d4b9b7ba4d48f90975c3ae864c1afc487ef1864e972ea7f4fdcba0ee174611f31384d2472bc9dbe5a6ccbdc3995800a13800e1e9bb1ba2426d1f93aad5
)

vcpkg_extract_source_archive(MUMPS_UPSTREAM_SOURCE_PATH
    ARCHIVE "${MUMPS_ARCHIVE}"
    SOURCE_BASE "${VERSION}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        single          BUILD_SINGLE
        double          BUILD_DOUBLE
        complex         BUILD_COMPLEX
        complex-double  BUILD_COMPLEX16
)

# Selects the Fortran compiler: the system gfortran on Linux/macOS, or the MinGW
# gfortran from the vcpkg-gfortran dependency on Windows. On Windows this also
# switches the whole port to the MinGW toolchain and forces dynamic linkage.
include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)
set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)

# The harness copies libseq.cmake into the extracted MUMPS source tree during
# configure, which both configurations share, so they must not run in parallel.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        ${FORTRAN_CMAKE}
        "-DFETCHCONTENT_SOURCE_DIR_MUMPS_UPSTREAM=${MUMPS_UPSTREAM_SOURCE_PATH}"
        "-DMUMPS_UPSTREAM_VERSION=${VERSION}"
        -DMUMPS_BUILD_TESTING=OFF
        # Sequential build: no MPI/ScaLAPACK. MUMPS ships a stub MPI (mpiseq).
        -DMUMPS_parallel=OFF
        -DMUMPS_scalapack=OFF
        # Resolve every optional dependency probe deterministically.
        -DMUMPS_USE_MKL=OFF
        -DMUMPS_metis=OFF
        -DMUMPS_parmetis=OFF
        -DMUMPS_scotch=OFF
        -DMUMPS_ptscotch=OFF
        -DMUMPS_openmp=OFF
        -DMUMPS_gpu=OFF
        -DMUMPS_xkblas=OFF
        -DMUMPS_matlab=OFF
        -DMUMPS_gemmt=OFF
        -DMUMPS_avx512=OFF
        -DMUMPS_intsize64=OFF
        -DMUMPS_find_static=OFF
        -DMUMPS_ENABLE_RPATH=OFF
    MAYBE_UNUSED_VARIABLES
        MUMPS_find_static
        MUMPS_USE_MKL
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mumps-solver CONFIG_PATH cmake)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/share/docs"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST
    "${MUMPS_UPSTREAM_SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/LICENSE"
)
