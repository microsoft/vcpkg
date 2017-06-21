cmake_minimum_required (VERSION 3.0)
project (fftw3 VERSION 3.3.6)

# From: http://stackoverflow.com/questions/10252336/fftw-in-visual-studio-2010

# Standard:          /DWIN32 /D_WINDOWS /W3 /Zm1000 /EHsc /GR
if (WIN32)
    add_definitions(-D_OPENMP -DLIBFFTWF33_EXPORTS /openmp /bigobj) # Visual Studio 2005 and up supports OpenMP
endif (WIN32)

if (BUILD_SHARED_LIBS)
    add_definitions(-DFFTW_DLL)
endif()


file(GLOB           fftw_api_SOURCE                 api/*.c             api/*.h)
file(GLOB           fftw_dft_SOURCE                 dft/*.c             dft/*.h)
file(GLOB           fftw_dft_scalar_SOURCE          dft/scalar/*.c      dft/scalar/*.h)
file(GLOB           fftw_dft_scalar_codelets_SOURCE dft/scalar/codelets/*.c     dft/scalar/codelets/*.h)
file(GLOB           fftw_dft_simd_SOURCE            dft/simd/*.c        dft/simd/*.h)

file(GLOB           fftw_dft_simd_sse2_SOURCE       dft/simd/sse2/*.c   dft/simd/sse2/*.h)
file(GLOB           fftw_kernel_SOURCE              kernel/*.c          kernel/*.h)
file(GLOB           fftw_rdft_SOURCE                rdft/*.c            rdft/*.h)
file(GLOB           fftw_rdft_scalar_SOURCE         rdft/scalar/*.c     rdft/scalar/*.h)

file(GLOB           fftw_rdft_scalar_r2cb_SOURCE    rdft/scalar/r2cb/*.c
                                                    rdft/scalar/r2cb/*.h)
file(GLOB           fftw_rdft_scalar_r2cf_SOURCE    rdft/scalar/r2cf/*.c
                                                    rdft/scalar/r2cf/*.h)
file(GLOB           fftw_rdft_scalar_r2r_SOURCE     rdft/scalar/r2r/*.c
                                                    rdft/scalar/r2r/*.h)

file(GLOB           fftw_rdft_simd_SOURCE           rdft/simd/*.c       rdft/simd/*.h)
file(GLOB           fftw_rdft_simd_sse2_SOURCE      rdft/simd/sse2/*.c  rdft/simd/sse2/*.h)

file(GLOB           fftw_reodft_SOURCE              reodft/*.c          reodft/*.h)
file(GLOB           fftw_simd_support_SOURCE        simd-support/*.c    simd-support/*.h)
#file(GLOB          fftw_threads_SOURCE             threads/*.c         threads/*.h)


set(${fftw_threads_SOURCE}
    threads/api.c
    threads/conf.c
    threads/ct.c
    threads/dft-vrank-qeq1.c
    threads/f77api.c
    threads/hc2hc.c
    threads/openmp.c
    threads/rdft-vrank-geq1.c
    threads/vrank-geq1-rdft2.c)


include_directories(
    kernel
    api
    dft
    dft/scalar
    dft/scalar/codelets # really needed?
    dft/simd
    dft/simd/sse2
    rdft
    rdft/scalar
    rdft/simd
    reodft
    ${CMAKE_CURRENT_SOURCE_DIR} # thats where the config.h is located
    simd-support
)

set(COMMON_SOURCES
    ${fftw_api_SOURCE}
    ${fftw_dft_SOURCE}
    ${fftw_dft_scalar_SOURCE}
    ${fftw_dft_scalar_codelets_SOURCE}
    ${fftw_dft_simd_SOURCE}
    ${fftw_kernel_SOURCE}
    ${fftw_rdft_SOURCE}
    ${fftw_rdft_scalar_SOURCE}

    ${fftw_rdft_scalar_r2cb_SOURCE}
    ${fftw_rdft_scalar_r2cf_SOURCE}
    ${fftw_rdft_scalar_r2r_SOURCE}

    ${fftw_rdft_simd_SOURCE}
    ${fftw_reodft_SOURCE}
    ${fftw_simd_support_SOURCE}
    ${fftw_threads_SOURCE}
)

set(SSE2_SOURCES
  ${fftw_dft_simd_sse2_SOURCE}
  ${fftw_rdft_simd_sse2_SOURCE}
)

# pkgconfig
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir  "${CMAKE_INSTALL_PREFIX}/lib")
set(includedir " ${CMAKE_INSTALL_PREFIX}/include")
set(VERSION ${PROJECT_VERSION})
set(INSTALL_PKGCONFIG_DIR "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" CACHE PATH "Installation directory for pkgconfig (.pc) files")

# Create default target for the library (double precision)
add_library(fftw3 ${COMMON_SOURCES} ${SSE2_SOURCES})
target_compile_definitions(fftw3 PRIVATE HAVE_SSE2)
set(INSTALL_TARGETS fftw3)
set(PREC_SUFFIX "")
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/fftw.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/fftw3.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/fftw3.pc" DESTINATION "${INSTALL_PKGCONFIG_DIR}")

# Optionally add single precision
if(BUILD_SINGLE)
    add_library(fftw3f ${COMMON_SOURCES} ${SSE2_SOURCES})
    target_compile_definitions(fftw3f PRIVATE FFTW_SINGLE BENCHFFT_SINGLE HAVE_SSE2)
    set(INSTALL_TARGETS ${INSTALL_TARGETS} fftw3f)
    set(PREC_SUFFIX "f")
    configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/fftw.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/fftw3f.pc @ONLY)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/fftw3f.pc" DESTINATION "${INSTALL_PKGCONFIG_DIR}")
endif(BUILD_SINGLE)

# Optionally add long-double precision (does not support SSE2)
if(BUILD_LONG_DOUBLE)
    add_library(fftw3l ${COMMON_SOURCES})
    target_compile_definitions(fftw3l PRIVATE FFTW_LDOUBLE BENCHFFT_LDOUBLE)
    set(INSTALL_TARGETS ${INSTALL_TARGETS} fftw3l)
    set(PREC_SUFFIX "l")
    configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/fftw.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/fftw3l.pc @ONLY)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/fftw3l.pc" DESTINATION "${INSTALL_PKGCONFIG_DIR}")
endif(BUILD_LONG_DOUBLE)


install(TARGETS ${INSTALL_TARGETS}
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)
