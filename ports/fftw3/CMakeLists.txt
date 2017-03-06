cmake_minimum_required (VERSION 3.0)
project (fftw3)

# From: http://stackoverflow.com/questions/10252336/fftw-in-visual-studio-2010

# Standard:          /DWIN32 /D_WINDOWS /W3 /Zm1000 /EHsc /GR
if (WIN32)
        set(CMAKE_CXX_FLAGS "/DWIN32 /D_WINDOWS /W4 /Zi /EHsc /GR- /MP /openmp /bigobj")
        add_definitions(-D_OPENMP -DFFTW_DLL -DLIBFFTWF33_EXPORTS) # Visual Studio 2005 and up supports OpenMP
endif (WIN32)


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
    dft/scalar/codelets # rellay needed?
    dft/simd
    dft/simd/sse2
    rdft
    rdft/scalar
    rdft/simd
    reodft
    ${CMAKE_CURRENT_SOURCE_DIR} # thats where the config.h is located
    simd-support
)

# Create a target for the library
add_library(fftw3
    ${fftw_api_SOURCE}
    ${fftw_dft_SOURCE}
    ${fftw_dft_scalar_SOURCE}
    ${fftw_dft_scalar_codelets_SOURCE}
    ${fftw_dft_simd_SOURCE}
    ${fftw_dft_simd_sse2_SOURCE}
    ${fftw_kernel_SOURCE}
    ${fftw_rdft_SOURCE}
    ${fftw_rdft_scalar_SOURCE}

    ${fftw_rdft_scalar_r2cb_SOURCE}
    ${fftw_rdft_scalar_r2cf_SOURCE}
    ${fftw_rdft_scalar_r2r_SOURCE}

    ${fftw_rdft_simd_SOURCE}
    ${fftw_rdft_simd_sse2_SOURCE}
    ${fftw_reodft_SOURCE}
    ${fftw_simd_support_SOURCE}
    ${fftw_threads_SOURCE}
)

install(TARGETS fftw3
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)
