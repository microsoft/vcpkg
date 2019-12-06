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

set(kissfft_sources kiss_fft.c)

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


# References:
# https://stackoverflow.com/questions/47611209/cmake-multiple-option-setting
# https://stackoverflow.com/questions/19982340/cmake-compare-to-empty-string-with-strequal-failed
# https://github.com/QuantStack/xeus-cling/blob/b3248732e8dac904dd868d3eb54b85acbcdf00d2/CMakeLists.txt#L298
# https://docs.microsoft.com/en-us/cpp/build/exporting-from-a-dll-using-def-files?view=vs-2019
# https://stackoverflow.com/questions/38296756/what-is-the-idiomatic-way-in-cmake-to-add-the-fpic-compiler-option
# https://stackoverflow.com/questions/7894633/disabling-msse
# https://stackoverflow.com/questions/58007793/using-cmake-to-make-a-library-without-sse-support-windows-version
# https://github.com/opencv/opencv/blob/master/cmake/OpenCVCompilerOptimizations.cmake
# https://stackoverflow.com/questions/6901369/how-to-detect-sse-availability-in-cmake
