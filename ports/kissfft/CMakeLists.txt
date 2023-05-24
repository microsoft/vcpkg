cmake_minimum_required(VERSION 3.14)

project(kissfft LANGUAGES C)

include(GNUInstallDirs)

option(KF_USE_SIMD "Use SIMD" OFF)
option(KF_INSTALL_HEADERS "Install header files" ON)

if (KF_USE_SIMD)
    set(KF_SCALAR_TYPE "__m128" CACHE STRING "Definition of kiss_fft_scalar")
else ()
    set(KF_SCALAR_TYPE "float" CACHE STRING "Definition of kiss_fft_scalar")
endif ()

# TODO: FIXED_POINT
# TODO: -msse

set(kissfft_sources kiss_fft.c kiss_fftr.c kiss_fftnd.c kiss_fftndr.c)

if (WIN32 AND BUILD_SHARED_LIBS)
    list(APPEND kissfft_sources exports.def)
endif ()

add_library(kissfft ${kissfft_sources})

if (BUILD_SHARED_LIBS)
    set_property(
        TARGET kissfft
        PROPERTY POSITION_INDEPENDENT_CODE ON
    )
endif ()

target_include_directories(
    kissfft
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_compile_definitions(
    kissfft
    PUBLIC
        $<$<BOOL:${KF_USE_SIMD}>:USE_SIMD>
        kiss_fft_scalar=${KF_SCALAR_TYPE}
)

if (KF_INSTALL_HEADERS)
    install(
        FILES
            _kiss_fft_guts.h
            kiss_fft.h
            kiss_fftr.h
            kiss_fftnd.h
            kiss_fftndr.h
            kissfft.hh
            kissfft_i32.hh
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif ()

install(TARGETS kissfft EXPORT unofficial-kissfft-config)

install(
    EXPORT unofficial-kissfft-config
    NAMESPACE unofficial::kissfft::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-kissfft
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
