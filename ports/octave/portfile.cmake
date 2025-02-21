vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftpmirror.gnu.org/octave/octave-${VERSION}.tar.xz"
         "https://ftp.gnu.org/gnu/octave/octave-${VERSION}.tar.xz"
    FILENAME "octave-${VERSION}.tar.xz"
    SHA512 9550162681aee88b4bcb94c5081ed0470df0d3f7c5307b25878b94b19f1282002ba69f0c4c79877e81f61122bfba1b2671ed5007a28fbb2d755bda466a3c46d8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        run-mk-ops.diff
        dep_pc_names.patch
)

include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN)

vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_EXE_PATH "${BISON}" DIRECTORY)
vcpkg_add_to_path("${BISON_EXE_PATH}")

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_EXE_PATH "${FLEX}" DIRECTORY)
vcpkg_add_to_path("${FLEX_EXE_PATH}")

vcpkg_find_acquire_program(GPERF)
get_filename_component(GPERF_EXE_PATH "${GPERF}" DIRECTORY)
vcpkg_add_to_path("${GPERF_EXE_PATH}")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

if(VCPKG_HOST_IS_OSX)
    message("${PORT} currently requires the following programs from the system package manager:\n    gsed\n\nIt can be installed with brew gnu-sed")
endif()

if("bz2" IN_LIST FEATURES)
    set(BZ2_OPTION "yes")
else()
    set(BZ2_OPTION "no")
endif()

set(SUITESPARSECONFIG_OPTION "no")

if("amd" IN_LIST FEATURES)
    set(AMD_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(AMD_OPTION "no")
endif()

if("camd" IN_LIST FEATURES)
    set(CAMD_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(CAMD_OPTION "no")
endif()

if("ccolamd" IN_LIST FEATURES)
    set(CCOLAMD_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(CCOLAMD_OPTION "no")
endif()

if("cholmod" IN_LIST FEATURES)
    set(CHOLMOD_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(CHOLMOD_OPTION "no")
endif()

if("colamd" IN_LIST FEATURES)
    set(COLAMD_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(COLAMD_OPTION "no")
endif()

if("cxsparse" IN_LIST FEATURES)
    set(CXSPARSE_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(CXSPARSE_OPTION "no")
endif()

if("klu" IN_LIST FEATURES)
    set(KLU_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(KLU_OPTION "no")
endif()

if("umfpack" IN_LIST FEATURES)
    set(UMFPACK_OPTION "yes")
    set(SUITESPARSECONFIG_OPTION "yes")
else()
    set(UMFPACK_OPTION "no")
endif()

if("hdf5" IN_LIST FEATURES)
    set(HDF5_OPTION "yes")
else()
    set(HDF5_OPTION "no")
endif()

if("fltk" IN_LIST FEATURES)
    set(FLTK_OPTION "yes")
else()
    set(FLTK_OPTION "no")
endif()

if("fontconfig" IN_LIST FEATURES)
    set(FONTCONFIG_OPTION "yes")
else()
    set(FONTCONFIG_OPTION "no")
endif()

if("freetype" IN_LIST FEATURES)
    set(FREETYPE_OPTION "yes")
else()
    set(FREETYPE_OPTION "no")
endif()

vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/tools/fltk")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
    --disable-docs
    --disable-java
    --disable-hg-id
    --enable-lib-visibility-flags
    --enable-relocate-all
    --with-amd=${AMD_OPTION}
    --with-arpack=no
    --with-bz2=${BZ2_OPTION}
    --with-camd=${CAMD_OPTION}
    --with-ccolamd=${CCOLAMD_OPTION}
    --with-cholmod=${CHOLMOD_OPTION}
    --with-colamd=${COLAMD_OPTION}
    --with-cxsparse=${CXSPARSE_OPTION}
    --with-curl=no
    --with-fftw3 # yes
    --with-fftw3f # yes
    --with-fltk=${FLTK_OPTION}
    --with-fontconfig=${FONTCONFIG_OPTION}
    --with-freetype=${FREETYPE_OPTION}
    --with-glpk # yes
    --with-hdf5=${HDF5_OPTION}
    --with-klu=${KLU_OPTION}
    --with-magick=no
    --with-opengl # yes
    --with-portaudio=no
    --with-pcre2 # yes
    --with-qhull_r=no
    --with-qrupdate=no
    --with-qscintilla=no
    --with-qt=no
    --with-sndfile # yes
    --with-spqr=no
    --with-suitesparseconfig=${SUITESPARSECONFIG_OPTION}
    --with-sundials_ida=no
    --with-sundials_nvecserial=no
    --with-umfpack=${UMFPACK_OPTION}
    --with-z # yes
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
foreach(subdir IN ITEMS libexec lib/octave/site lib/octave/${VERSION}/site share/octave/octave/${VERSION}/site share/octave/octave/site/api-v59)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${subdir}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/${subdir}")
endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
