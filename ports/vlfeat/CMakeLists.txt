cmake_minimum_required(VERSION 3.10)
project(vlfeat LANGUAGES C)

if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

if(MSVC)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
  add_definitions(-D__LITTLE_ENDIAN__)
  add_compile_options(/Zp8)
  add_compile_options(/wd4146)
  if(CMAKE_C_FLAGS MATCHES "/W[0-4]")
    string(REGEX REPLACE "/W[0-4]" "/W1" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
  endif()
endif()

if(CMAKE_COMPILER_IS_GNUCC)
  add_compile_options(-Wno-unused-function)
  add_compile_options(-Wno-long-long)
  add_compile_options(-Wno-variadic-macros)
endif()

if(USE_SSE)
  add_definitions(-D__SSE2__)
  set(SSE2_VL_C_FILES "vl/mathop_sse2.c" "vl/imopv_sse2.c")
  set(SSE2_VL_H_FILES "vl/mathop_sse2.h" "vl/imopv_sse2.h")
else()
  add_definitions(-DVL_DISABLE_SSE2)
endif()

if(USE_AVX)
  set(AVX_VL_C_FILES "vl/mathop_avx.c")
  set(AVX_VL_H_FILES "vl/mathop_avx.h")
else()
  add_definitions(-DVL_DISABLE_AVX)
endif()


set (C_SOURCES
  vl/aib.c
  vl/array.c
  vl/covdet.c
  vl/dsift.c
  vl/fisher.c
  vl/generic.c
  vl/getopt_long.c
  vl/gmm.c
  vl/hikmeans.c
  vl/hog.c
  vl/homkermap.c
  vl/host.c
  vl/ikmeans.c
  vl/imopv.c
  vl/kdtree.c
  vl/kmeans.c
  vl/lbp.c
  vl/liop.c
  vl/mathop.c
  ${AVX_VL_C_FILES}
  ${SSE2_VL_C_FILES}
  vl/mser.c
  vl/pgm.c
  vl/quickshift.c
  vl/random.c
  vl/rodrigues.c
  vl/scalespace.c
  vl/sift.c
  vl/slic.c
  vl/stringop.c
  vl/svm.c
  vl/svmdataset.c
  vl/vlad.c
)

set (H_SOURCES
  vl/aib.h
  vl/array.h
  vl/covdet.h
  vl/dsift.h
  vl/fisher.h
  vl/generic.h
  vl/getopt_long.h
  vl/gmm.h
  vl/heap-def.h
  vl/hikmeans.h
  vl/hog.h
  vl/homkermap.h
  vl/host.h
  vl/ikmeans.h
  vl/imopv.h
  vl/kdtree.h
  vl/kmeans.h
  vl/lbp.h
  vl/liop.h
  vl/mathop.h
  ${AVX_VL_H_FILES}
  ${SSE2_VL_H_FILES}
  vl/mser.h
  vl/pgm.h
  vl/qsort-def.h
  vl/quickshift.h
  vl/random.h
  vl/rodrigues.h
  vl/scalespace.h
  vl/shuffle-def.h
  vl/sift.h
  vl/slic.h
  vl/stringop.h
  vl/svm.h
  vl/svmdataset.h
  vl/vlad.h
)

include(GNUInstallDirs)

add_library(vl ${C_SOURCES} ${H_SOURCES})
set_property(TARGET vl PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(vl PRIVATE -DVL_BUILD_DLL)
target_include_directories(vl PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
target_compile_features(vl PRIVATE c_std_99)

if(ENABLE_OPENMP)
  find_package(OpenMP REQUIRED)
  # PRIVATE because '#pragma omp' is only used in .c files
  target_link_libraries(vl PRIVATE OpenMP::OpenMP_C)
endif()

install(TARGETS vl
    EXPORT vlfeatTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(FILES ${H_SOURCES} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/vl")

install(EXPORT vlfeatTargets
  FILE vlfeatConfig.cmake
  NAMESPACE unofficial::vlfeat::
  DESTINATION "share/vlfeat"
)
