cmake_minimum_required (VERSION 3.10)
project (vlfeat)

set(INSTALL_BIN_DIR      "bin"                      CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                      CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include/vlfeat"           CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/vlfeat"             CACHE PATH "Path where cmake configs will be installed")

# Make relative paths absolute (needed later on)
set(RELATIVE_INSTALL_INCLUDE_DIR ${INSTALL_INCLUDE_DIR})
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

# make sure that the default is a RELEASE
set(default_build_type "Release")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
      STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

if(ENABLE_OPENMP)
  find_package(OpenMP REQUIRED)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
endif()

if(MSVC)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
  add_definitions(-D__LITTLE_ENDIAN__)
  add_definitions(/Zp8)
  add_definitions(/wd4146)
  if(CMAKE_C_FLAGS MATCHES "/W[0-4]")
    string(REGEX REPLACE "/W[0-4]" "/W1" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
  endif()
endif()

if(CMAKE_COMPILER_IS_GNUCC)
  add_definitions(-std=c99)
  add_definitions(-Wno-unused-function)
  add_definitions(-Wno-long-long)
  add_definitions(-Wno-variadic-macros)
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

add_library(vl ${C_SOURCES} ${H_SOURCES})
set_property(TARGET vl PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(vl PRIVATE -DVL_BUILD_DLL)
target_include_directories(vl PUBLIC $<INSTALL_INTERFACE:${RELATIVE_INSTALL_INCLUDE_DIR}> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/vl>)
set_target_properties(vl PROPERTIES PUBLIC_HEADER "${H_SOURCES}")

install(TARGETS vl EXPORT vlfeatTargets
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
  PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}"
  COMPONENT dev
)

install(EXPORT vlfeatTargets
  FILE vlfeatConfig.cmake
  NAMESPACE unofficial::vlfeat::
  DESTINATION "${INSTALL_CMAKE_DIR}"
)
