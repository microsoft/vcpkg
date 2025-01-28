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

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
    --disable-docs
    --disable-java
    --disable-hg-id
    --enable-lib-visibility-flags
    --enable-relocate-all
    --with-amd=no
    --with-arpack=no
    --with-bz2=no
    --with-camd=no
    --with-ccolamd=no
    --with-cholmod=no
    --with-colamd=no
    --with-cxsparse=no
    --with-curl=no
    --with-cxsparse=no
    --with-fftw3 # yes
    --with-fftw3f # yes
    --with-fltk=no
    --with-fontconfig=no
    --with-freetype=no
    --with-glpk # yes
    --with-hdf5=no
    --with-klu=no
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
    --with-suitesparseconfig=no
    --with-sundials_ida=no
    --with-sundials_nvecserial=no
    --with-umfpack=no
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
