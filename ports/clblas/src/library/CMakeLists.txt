# ########################################################################
# Copyright 2013 Advanced Micro Devices, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ########################################################################

find_package(PythonInterp REQUIRED)



################################################################################
# AutoGemm Begin
################################################################################

# AutoGemm scripts and out files
set(AUTOGEMM_SCRIPTS
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/AutoGemm.py
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/AutoGemmParameters.py
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/Common.py
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/Includes.py
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/KernelOpenCL.py
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/KernelParameters.py
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/KernelSelection.py
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/KernelsToPreCompile.py
)
set(AUTOGEMM_HEADERS
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmClKernels.h
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelBuildOptionsBinary.h
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelBinaries.h
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelSelection.h
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelSelectionSpecific.h
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelBuildOptionsSource.h
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelSources.h
)

set(AUTOGEMM_SRC
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmClKernels.cpp
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelBuildOptionsBinary.cpp
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelBinaries.cpp
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelSelection.cpp
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelSelectionSpecific.cpp
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelBuildOptionsSource.cpp
  ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelSources.cpp
)

set(USERGEMM_SRC
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/UserGemmKernelSources/UserGemmClKernels.cc
)

set(USERGEMM_HEADERS
   ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/UserGemmKernelSources/UserGemmKernelSourceIncludes.h
   ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/UserGemmKernelSources/UserGemmClKernels.h
)

set(AUTOGEMM_TEST_SRC
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/AutoGemmTools/TestAutoGemm.cpp
)
set(AUTOGEMM_PROFILER_SRC
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/AutoGemmTools/ProfileAutoGemm.cpp
)
set(AUTOGEMM_PRECOMPILE_SRC
  ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/AutoGemmTools/AutoGemmPreCompileKernels.cpp
)
set( AUTOGEMM_PRECOMPILED_KERNELS
  ${CMAKE_BINARY_DIR}/include/AutoGemmKernelBinaries/AutoGemmKernelBinariesPreCompiled.h
)

# AutoGemm options for pre-compiling kernels
option( PRECOMPILE_GEMM_PRECISION_SGEMM "AutoGemm: pre-compile sgemm kernels" OFF)
option( PRECOMPILE_GEMM_PRECISION_DGEMM "AutoGemm: pre-compile dgemm kernels" OFF)
option( PRECOMPILE_GEMM_PRECISION_CGEMM "AutoGemm: pre-compile cgemm kernels" OFF)
option( PRECOMPILE_GEMM_PRECISION_ZGEMM "AutoGemm: pre-compile zgemm kernels" OFF)

option( PRECOMPILE_GEMM_TRANS_NN "AutoGemm: pre-compile NN transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_NT "AutoGemm: pre-compile NT transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_NC "AutoGemm: pre-compile NC transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_TN "AutoGemm: pre-compile TN transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_TT "AutoGemm: pre-compile TT transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_TC "AutoGemm: pre-compile TC transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_CN "AutoGemm: pre-compile CN transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_CT "AutoGemm: pre-compile CT transpose cases" OFF)
option( PRECOMPILE_GEMM_TRANS_CC "AutoGemm: pre-compile CC transpose cases" OFF)

option( INSTALL_SRC "Install source tree" OFF )

set( AUTOGEMM_ARCHITECTURE "Hawaii" CACHE STRING "AutoGemm: device for kernel selection logic" )
set_property( CACHE AUTOGEMM_ARCHITECTURE PROPERTY STRINGS "Hawaii" "Fiji" )



# opencl compiler version
#set( PRECOMPILE_GEMM_OPENCL_VERSION "2.0" CACHE STRING "OpenCL compiler version supported by device driver." )
#set_property( CACHE PRECOMPILE_GEMM_OPENCL_VERSION PROPERTY STRINGS 2.0 1.2 1.1 )
#message( STATUS "AutoGemm PreCompiler will use OpenCL ${PRECOMPILE_GEMM_OPENCL_VERSION} compiler." )

# PreCompile precision selected?
set( PRECOMPILE_GEMM_PRECISION_SELECTED OFF)
if (   PRECOMPILE_GEMM_PRECISION_SGEMM
    OR PRECOMPILE_GEMM_PRECISION_DGEMM
    OR PRECOMPILE_GEMM_PRECISION_CGEMM
    OR PRECOMPILE_GEMM_PRECISION_ZGEMM )
  set( PRECOMPILE_GEMM_PRECISION_SELECTED ON)
endif()

# PreCompile transpose selected?
set( PRECOMPILE_GEMM_TRANS_SELECTED OFF)
if (   PRECOMPILE_GEMM_TRANS_NN
    OR PRECOMPILE_GEMM_TRANS_NT
    OR PRECOMPILE_GEMM_TRANS_NC
    OR PRECOMPILE_GEMM_TRANS_TN
    OR PRECOMPILE_GEMM_TRANS_TT
    OR PRECOMPILE_GEMM_TRANS_TC
    OR PRECOMPILE_GEMM_TRANS_CN
    OR PRECOMPILE_GEMM_TRANS_CT
    OR PRECOMPILE_GEMM_TRANS_CC )
  set( PRECOMPILE_GEMM_TRANS_SELECTED ON)
endif()

# PreCompile is valid and active?
set( PRECOMPILE_GEMM_ACTIVE OFF)
if ( PRECOMPILE_GEMM_PRECISION_SELECTED
    AND PRECOMPILE_GEMM_TRANS_SELECTED)
  # valid selection
  set( PRECOMPILE_GEMM_ACTIVE ON)
  MESSAGE( STATUS "AutoGemm-PreCompile: selected kernels will be pre-compiled." )
elseif(NOT PRECOMPILE_GEMM_PRECISION_SELECTED
    AND NOT PRECOMPILE_GEMM_TRANS_SELECTED)
  MESSAGE( STATUS "AutoGemm-PreCompile: no kernels to be pre-compiled." )
else()
  MESSAGE( SEND_ERROR "AutoGemm-PreCompile: To pre-compile gemm kernels, select at lease one option from each of PRECOMPILE_GEMM_PRECISION_* and PRECOMPILE_GEMM_TRANS_*; otherwise, unselect all PRECOMPILE_GEMM_* options to not pre-compile any gemm kernels." )
endif()

# build commandline argument for AutoGemm
set( AGPC_ARGS --output ${CMAKE_BINARY_DIR}/include )

if ( PRECOMPILE_GEMM_ACTIVE )
  # precisions
  set(AGPC_ARGS ${AGPC_ARGS} --precisions )
  if (PRECOMPILE_GEMM_PRECISION_SGEMM)
    set(AGPC_ARGS ${AGPC_ARGS} s )
  endif()
  if (PRECOMPILE_GEMM_PRECISION_DGEMM)
    set(AGPC_ARGS ${AGPC_ARGS} d )
  endif()
  if (PRECOMPILE_GEMM_PRECISION_CGEMM)
    set(AGPC_ARGS ${AGPC_ARGS} c )
  endif()
  if (PRECOMPILE_GEMM_PRECISION_ZGEMM)
    set(AGPC_ARGS ${AGPC_ARGS} z )
  endif()

  # orders
  set(AGPC_ARGS ${AGPC_ARGS} --orders clblasColumnMajor )

  # transposes
  set(AGPC_ARGS ${AGPC_ARGS} --transposes )
  if (PRECOMPILE_GEMM_TRANS_NN)
    set(AGPC_ARGS ${AGPC_ARGS} NN )
  endif()
  if (PRECOMPILE_GEMM_TRANS_NT)
    set(AGPC_ARGS ${AGPC_ARGS} NT )
  endif()
  if (PRECOMPILE_GEMM_TRANS_NC)
    set(AGPC_ARGS ${AGPC_ARGS} NC )
  endif()
  if (PRECOMPILE_GEMM_TRANS_TN)
    set(AGPC_ARGS ${AGPC_ARGS} TN )
  endif()
  if (PRECOMPILE_GEMM_TRANS_TT)
    set(AGPC_ARGS ${AGPC_ARGS} TT )
  endif()
  if (PRECOMPILE_GEMM_TRANS_TC)
    set(AGPC_ARGS ${AGPC_ARGS} TC )
  endif()
  if (PRECOMPILE_GEMM_TRANS_CN)
    set(AGPC_ARGS ${AGPC_ARGS} CN )
  endif()
  if (PRECOMPILE_GEMM_TRANS_CT)
    set(AGPC_ARGS ${AGPC_ARGS} CT )
  endif()
  if (PRECOMPILE_GEMM_TRANS_CC)
    set(AGPC_ARGS ${AGPC_ARGS} CC )
  endif()

  # betas
  set(AGPC_ARGS ${AGPC_ARGS} --betas 0 1 )



################################################################################
# add target for generating pre-compile WhichKernels header
################################################################################
set( AUTOGEMM_PRECOMPILE_HEADER_SRC ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/KernelsToPreCompile.py )
set( AUTOGEMM_PRECOMPILE_HEADER_OUT ${CMAKE_BINARY_DIR}/include/AutoGemmIncludes/AutoGemmKernelsToPreCompile.h )
add_custom_command(
  OUTPUT ${AUTOGEMM_PRECOMPILE_HEADER_OUT}
  COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/KernelsToPreCompile.py ${AGPC_ARGS}
  DEPENDS ${AUTOGEMM_PRECOMPILE_HEADER_SRC}
)

################################################################################
# add target for compiling pre-compile executable
################################################################################
add_executable(AutoGemm_PreCompile_Bin
  ${AUTOGEMM_PRECOMPILE_SRC}
  ${AUTOGEMM_PRECOMPILE_HEADER_OUT}
  ${AUTOGEMM_HEADERS}
  ${AUTOGEMM_SRC}
  ${AUTOGEMM_SCRIPTS}
  )
target_link_libraries(AutoGemm_PreCompile_Bin ${OPENCL_LIBRARIES})
set_property( TARGET AutoGemm_PreCompile_Bin PROPERTY FOLDER "AutoGemm")
#set_target_properties(
  #AutoGemm_PreCompile_Bin
  #PROPERTIES
  #EXCLUDE_FROM_ALL TRUE
  #EXCLUDE_FROM_DEFAULT_BUILD TRUE
#)


################################################################################
# add target for running pre-compile executable
################################################################################
add_custom_command(
  OUTPUT ${AUTOGEMM_PRECOMPILED_KERNELS}
  COMMAND AutoGemm_PreCompile_Bin ${CMAKE_BINARY_DIR}
  DEPENDS AutoGemm_PreCompile_Bin
)

endif()#endif precompile active


################################################################################
# add target for main AutoGemm headers / source
################################################################################
add_custom_command(
  OUTPUT ${AUTOGEMM_HEADERS} ${AUTOGEMM_SRC}
  COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/library/blas/AutoGemm/AutoGemm.py --output-path ${CMAKE_BINARY_DIR}/include --opencl-compiler-version ${OPENCL_VERSION} --architecture ${AUTOGEMM_ARCHITECTURE}
  DEPENDS ${AUTOGEMM_SCRIPTS}
)


include_directories(
    ${OPENCL_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_BINARY_DIR}/include
    .
)

################################################################################
# AutoGemm Tools
################################################################################
add_executable(AutoGemm_Tools_Test
  ${AUTOGEMM_TEST_SRC}
  ${AUTOGEMM_SRC}
  ${AUTOGEMM_HEADERS}
  ${AUTOGEMM_SCRIPTS}
  )
target_link_libraries(AutoGemm_Tools_Test ${OPENCL_LIBRARIES})
set_property( TARGET AutoGemm_Tools_Test PROPERTY FOLDER "AutoGemm")
set_target_properties(
  AutoGemm_Tools_Test
  PROPERTIES
  EXCLUDE_FROM_ALL TRUE
  EXCLUDE_FROM_DEFAULT_BUILD TRUE
)


add_executable(AutoGemm_Tools_Profile
  ${AUTOGEMM_PROFILER_SRC}
  ${AUTOGEMM_SRC}
  ${AUTOGEMM_HEADERS}
  ${AUTOGEMM_SCRIPTS}
  )
target_link_libraries(AutoGemm_Tools_Profile ${OPENCL_LIBRARIES})
set_property( TARGET AutoGemm_Tools_Profile PROPERTY FOLDER "AutoGemm")
set_target_properties(
  AutoGemm_Tools_Profile
  PROPERTIES
  EXCLUDE_FROM_ALL TRUE
  EXCLUDE_FROM_DEFAULT_BUILD TRUE
)

source_group(AutoGemm\\scripts FILES ${AUTOGEMM_SCRIPTS} )
source_group(AutoGemm\\include FILES ${AUTOGEMM_HEADERS} )
source_group(AutoGemm\\src FILES ${AUTOGEMM_SRC} ${AUTOGEMM_PRECOMPILED_KERNELS} )

################################################################################
# AutoGemm End
################################################################################

################################################################################
# BEGIN Pre Compile General (static) Kernels
################################################################################
# options for pre-compiling trsm kernels
option( PRECOMPILE_TRSM_STRSM "pre-compile available dtrsm kernels" OFF )
option( PRECOMPILE_TRSM_DTRSM "pre-compile available strsm kernels" OFF )
if(PRECOMPILE_TRSM_DTRSM)
add_definitions(-DCLBLAS_OFFLINE_COMPILE_DTRSM)
message(STATUS "precompile DTRSM kernels.")
endif()
if(PRECOMPILE_TRSM_STRSM)
add_definitions(-DCLBLAS_OFFLINE_COMPILE_STRSM)
message(STATUS "precompile STRSM kernels. (not yet implemented)")
endif()


################################################################################
# END Pre Compile General (static) Kernels
################################################################################

set(SRC_BLAS
    blas/init.c
    blas/impl.c
    blas/scimage.c
    blas/xgemv.c
    blas/xsymv.c
    blas/xgemm.cc
    blas/xtrmm.c
    blas/xtrsm.cc
    blas/xsyrk.c
    blas/xsyr2k.c
    blas/xtrmv.c
    blas/xtrsv.c
    blas/xsymm.c
    blas/xgemm2.c
    blas/xger.c
    blas/xsyr.c
    blas/xsyr2.c
    blas/xher.c
    blas/xher2.c
    blas/xhemv.c
    blas/xhemm.c
    blas/xherk.c
    blas/xhpmv.c
    blas/xspmv.c
    blas/xgbmv.c
    blas/xtbmv.c
    blas/xshbmv.c
    blas/xtbsv.c
    blas/xher2k.c
    blas/xswap.c
    blas/xscal.cc
    blas/xcopy.c
    blas/xaxpy.c
    blas/xdot.c
    blas/xrotg.c
    blas/xrotmg.c
    blas/xrot.c
    blas/xrotm.c
    blas/ixamax.c
    blas/xnrm2.c
    blas/xasum.c
    blas/matrix.c
    blas/fill.cc
    blas/functor/functor.cc
    blas/functor/functor_selector.cc
    blas/functor/functor_xgemm.cc
    blas/functor/functor_xscal.cc
    blas/functor/functor_xtrsm.cc
    blas/functor/functor_xscal_generic.cc
    blas/functor/tahiti.cc
    blas/functor/hawaii.cc
	blas/functor/bonaire.cc
    blas/functor/gcn_dgemm.cc
    blas/functor/gpu_dtrsm.cc
    blas/functor/gpu_dtrsm192.cc
    blas/functor/functor_fill.cc
	blas/functor/hawaii_dgemmChannelConflict.cc
	blas/functor/hawaii_dgemmSplitKernel.cc
	blas/functor/hawaii_sgemmSplitKernel.cc
	blas/functor/hawaii_sgemmSplit64_32.cc
	blas/functor/gcn_dgemmCommon.cc
	blas/functor/gcn_sgemm.cc
	blas/functor/gcn_zgemm.cc
	blas/functor/gcn_dgemmSmallMatrices.cc
	blas/functor/gcn_sgemmSmallMatrices.cc
	blas/functor/hawaii_sgemmBranchKernel.cc
	blas/functor/hawaii_sgemmBig1024Kernel.cc
	blas/specialCases/GemmSpecialCases.cpp
)

set(SRC_BLAS_HEADERS
    blas/include/blas_funcs.h
    blas/include/matrix_dims.h
    blas/include/matrix_props.h
    blas/include/blas_mempat.h
    blas/include/clblas-internal.h
    blas/include/solution_seq.h
    blas/include/events.h
	blas/include/xgemm.h
    blas/functor/include/functor.h
    blas/functor/include/functor_xgemm.h
    blas/functor/include/functor_xscal.h
    blas/functor/include/functor_xtrsm.h
    blas/functor/include/functor_xscal_generic.h
    blas/functor/include/functor_selector.h
    blas/functor/include/tahiti.h
    blas/functor/include/hawaii.h
	blas/functor/include/bonaire.h
    blas/functor/include/gcn_dgemm.h
    blas/functor/include/gpu_dtrsm.h
    blas/functor/include/gpu_dtrsm192.h
    blas/functor/include/BinaryBuild.h
	blas/functor/include/hawaii_dgemmChannelConflict.h
	blas/functor/include/hawaii_dgemmSplitKernel.h
	blas/functor/include/hawaii_sgemmSplitKernel.h
	blas/functor/include/hawaii_sgemmSplit64_32.h
	blas/functor/include/gcn_dgemmCommon.h
	blas/functor/include/gcn_sgemm.h
	blas/functor/include/gcn_zgemm.h
	blas/functor/include/gcn_dgemmSmallMatrices.h
	blas/functor/include/gcn_sgemmSmallMatrices.h
	blas/functor/include/hawaii_sgemmBranchKernel.h
	blas/functor/include/hawaii_sgemmBig1024Kernel.h
	blas/AutoGemm/UserGemmKernelSources/UserGemmClKernels.h
	blas/AutoGemm/UserGemmKernelSources/UserGemmKernelSourceIncludes.h
)

set(SRC_BLAS_GENERIC
    blas/generic/common.c
    blas/generic/common2.cc
    blas/generic/blas_funcs.c
    blas/generic/events.c
    blas/generic/matrix_props.c
    blas/generic/matrix_dims.c
    blas/generic/kdump.c
    blas/generic/solution_assert.c
    blas/generic/solution_seq.c
    blas/generic/solution_seq_make.c
    blas/generic/problem_iter.c
    blas/generic/kernel_extra.c
    blas/generic/binary_lookup.cc
    blas/generic/functor_cache.cc
)

set(SRC_BLAS_GENS
    blas/gens/gen_init.c
    blas/gens/blas_kgen.c
    blas/gens/blas_subgroup.c
    blas/gens/gen_helper.c
    blas/gens/tilemul.c
    blas/gens/fetch.c
    blas/gens/tile.c
    blas/gens/tile_iter.c
    blas/gens/decomposition.c
    blas/gens/gemv.c
    blas/gens/symv.c
    blas/gens/gemm.c
    blas/gens/trmm.c
    blas/gens/trsm.c
    blas/gens/syrxk.c
    blas/gens/trxm_common.c
    blas/gens/trsm_kgen.c
    blas/gens/xxmv_common.c
    blas/gens/legacy/blas_kgen_legacy.c
    blas/gens/legacy/gen_helper_legacy.c
    blas/gens/legacy/trxm_common_legacy.c
    blas/gens/legacy/trsm_kgen_legacy.c
    blas/gens/legacy/blkmul.c
    blas/gens/legacy/gemm_lds.c
    blas/gens/legacy/gemm_img.c
    blas/gens/legacy/trmm_lds.c
    blas/gens/legacy/trmm_img.c
    blas/gens/legacy/trsm_lds.c
    blas/gens/legacy/trsm_img.c
    blas/gens/legacy/trsm_cached_lds.c
    blas/gens/trmv_reg.cpp
    blas/gens/ger_lds.cpp
    blas/gens/trsv_trtri.cpp
    blas/gens/trsv_gemv.cpp
    blas/gens/kprintf.cpp
    blas/gens/syr_lds.cpp
    blas/gens/her_lds.cpp
    blas/gens/syr2_lds.cpp
    blas/gens/her2_lds.cpp
    blas/gens/symm_cached.cpp
    blas/gens/gemm_cached.cpp
    blas/gens/gemm_tail_cached.cpp
    blas/gens/gbmv.cpp
    blas/gens/tuned_numbers.c
    blas/gens/swap_reg.cpp
    blas/gens/scal_reg.cpp
    blas/gens/copy_reg.cpp
    blas/gens/axpy_reg.cpp
    blas/gens/dot.cpp
    blas/gens/reduction.cpp
    blas/gens/rotg_reg.cpp
    blas/gens/rotmg_reg.cpp
    blas/gens/rotm_reg.cpp
    blas/gens/iamax.cpp
    blas/gens/nrm2.cpp
    blas/gens/asum.cpp
)

#set (BIN_CL_TEMPLATES
#dgemm_hawai.cl
#dtrsm_gpu.cl
#)

set (SRC_CL_TEMPLATES
    gemm.cl
    gemm_helper.cl
    gbmv.cl
    ger.cl
    her.cl
    symm_helper.cl
    syr2_her2.cl
    syr_her.cl
    trsv.cl
    her2.cl
    symm.cl
    syr2.cl
    syr.cl
    trmv.cl
    trsv_gemv.cl
    swap.cl
    scal.cl
    copy.cl
    axpy.cl
    dot.cl
    reduction.cl
    rotg.cl
    rotmg.cl
    rotm.cl
    iamax.cl
    nrm2.cl
    asum.cl
    custom_gemm.cl
    dgemm_hawai.cl
	dgemm_hawaiiChannelConfilct.cl
	dgemm_hawaiiSplitKernel.cl
	sgemm_hawaiiSplitKernel.cl
    dtrsm_gpu.cl
    dtrsm_gpu192.cl
	dgemm_gcn_SmallMatrices.cl
	sgemm_gcn_SmallMatrices.cl
	sgemm_gcn_bigMatrices.cl
	sgemm_gcn.cl
	zgemm_gcn.cl
)

set(SRC_CL_TEMPLATES_GEN
    dgemm_hawai.clHawaii_64.bin.cl
    dtrsm_gpu.clHawaii_64.bin.cl
	dtrsm_gpu192.clHawaii_64.bin.cl
	dgemm_hawaiiChannelConfilct.clHawaii_64.bin.cl
	dgemm_hawaiiSplitKernel.clHawaii_64.bin.cl
	sgemm_hawaiiSplitKernel.clHawaii_64.bin.cl
	sgemm_hawaiiSplitKernel.clBonaire_64.bin.cl
    dgemm_hawai.clTahiti_64.bin.cl
    dtrsm_gpu.clTahiti_64.bin.cl
	dgemm_gcn_SmallMatrices.clHawaii_64.bin.cl
	dgemm_gcn_SmallMatrices.clTahiti_64.bin.cl
	sgemm_gcn_SmallMatrices.clHawaii_64.bin.cl
	sgemm_gcn_SmallMatrices.clTahiti_64.bin.cl
    sgemm_gcn_SmallMatrices.clBonaire_64.bin.cl
	sgemm_gcn_bigMatrices.clHawaii_64.bin.cl
	sgemm_gcn_bigMatrices.clTahiti_64.bin.cl
    sgemm_gcn_bigMatrices.clBonaire_64.bin.cl
	sgemm_gcn.clHawaii_64.bin.cl
	zgemm_gcn.clHawaii_64.bin.cl
    sgemm_gcn.clBonaire_64.bin.cl
	sgemm_gcn.clTahiti_64.bin.cl
	sgemm_hawaiiSplit64_32.clHawaii_64.bin.cl
)

set(SRC_BLAS_GENERIC_HEADERS
    blas/generic/solution_assert.h
    blas/generic/problem_iter.h
)

set(SRC_BLAS_GENS_HEADERS
    blas/gens/fetch.h
    blas/gens/blas_kgen.h
    blas/gens/blas_subgroup.h
    blas/gens/gen_helper.h
    blas/gens/init.h
    blas/gens/trxm_common.h
    blas/gens/trsm_kgen.h
    blas/gens/xxmv_common.h
    blas/gens/tile.h
    blas/gens/tile_iter.h
    blas/gens/tuned_numbers.h
)

set(SRC_COMMON
    common/list.c
    common/clkern.c
    common/kern_cache.c
    common/kerngen_core.c
    common/kgen_basic.c
    common/kgen_loop_helper.c
    common/kgen_guard.c
    common/misc.c
    common/devinfo.c
    common/devinfo-cache.c
    common/mutex.c
    common/rwlock.c
    common/trace_malloc.c
    common/md5sum.c
)

set(SRC_COMMON_GENS
    common/gens/dblock_kgen.c
)

set(SRC_TOOLS
    tools/tune/toolslib.c
    tools/tune/fileio.c
    tools/tune/dimension.c
    tools/tune/storage_init.c
    tools/tune/storage_io.c
    tools/tune/storage_data.c
)

set(CLBLAS_SOURCES
    ${SRC_COMMON} ${SRC_COMMON_GENS} ${SRC_BLAS} ${SRC_BLAS_GENERIC}
    ${SRC_BLAS_GENS} ${SRC_TOOLS} ../clBLAS.def
)
set(GLOBAL_HEADERS
    ${clBLAS_SOURCE_DIR}/clBLAS.h
    ${clBLAS_SOURCE_DIR}/clBLAS-complex.h
    ${clBLAS_SOURCE_DIR}/include/clkern.h
    ${clBLAS_SOURCE_DIR}/include/cltypes.h
    ${clBLAS_SOURCE_DIR}/include/dblock_kgen.h
    ${clBLAS_SOURCE_DIR}/include/defbool.h
    ${clBLAS_SOURCE_DIR}/include/devinfo.h
    ${clBLAS_SOURCE_DIR}/include/dis_warning.h
    ${clBLAS_SOURCE_DIR}/include/kern_cache.h
    ${clBLAS_SOURCE_DIR}/include/kernel_extra.h
    ${clBLAS_SOURCE_DIR}/include/kerngen.h
    ${clBLAS_SOURCE_DIR}/include/list.h
    ${clBLAS_SOURCE_DIR}/include/mempat.h
    ${clBLAS_SOURCE_DIR}/include/msvc.h
    ${clBLAS_SOURCE_DIR}/include/mutex.h
    ${clBLAS_SOURCE_DIR}/include/rwlock.h
    ${clBLAS_SOURCE_DIR}/include/solver.h
    ${clBLAS_SOURCE_DIR}/include/md5sum.h
    ${clBLAS_SOURCE_DIR}/include/binary_lookup.h
)

source_group(common FILES ${SRC_COMMON})
source_group(common\\gens FILES ${SRC_COMMON_GENS})
source_group(blas FILES ${SRC_BLAS})
source_group(blas\\include FILES ${SRC_BLAS_HEADERS})
source_group(blas\\generic FILES ${SRC_BLAS_GENERIC})
source_group(blas\\gens FILES ${SRC_BLAS_GENS} ${SRC_BLAS_GENS_HEADERS})

include_directories(${OPENCL_INCLUDE_DIRS}
    ${clBLAS_SOURCE_DIR}
    ${clBLAS_SOURCE_DIR}/include
    ${clBLAS_SOURCE_DIR}/library/blas/include
    ${clBLAS_SOURCE_DIR}/library/blas/functor/include
    ${clBLAS_SOURCE_DIR}/library/tools/tune
    ${clBLAS_BINARY_DIR}/include
    ${clBLAS_SOURCE_DIR}/library/blas/AutoGemm
	${clBLAS_SOURCE_DIR}/library/blas/AutoGemm/UserGemmKernelSources
	${clBLAS_SOURCE_DIR}/library/blas/specialCases/include
	${clBLAS_SOURCE_DIR}/library/blas/trtri
)

option( BLAS_DUMP_CLBLAS_KERNELS "Force the library to dump OpenCL kernels to disk" OFF )
if( BLAS_DUMP_CLBLAS_KERNELS )
    add_definitions( -DDUMP_CLBLAS_KERNELS )
endif()

option( BLAS_KEEP_KERNEL_SOURCES "Prevent the library from stripping source from kernels" ON )
if( BLAS_KEEP_KERNEL_SOURCES )
    add_definitions( -DKEEP_CLBLAS_KERNEL_SOURCES )
endif()

option( BLAS_TRACE_MALLOC "Simple functionality to track memory leaks" OFF )
if( BLAS_TRACE_MALLOC )
    add_definitions( -DTRACE_MALLOC )
endif()

option( BLAS_PRINT_BUILD_ERRORS "Enable printing of OpenCL compiler errors on stdout" ON )
if( BLAS_PRINT_BUILD_ERRORS )
    add_definitions( -DPRINT_BUILD_ERRORS )
endif()

include( ExternalProject )
ExternalProject_Add( tplgen
    URL "${CMAKE_SOURCE_DIR}/library/tools/tplgen"
    INSTALL_COMMAND ""
)

################OCLBinaryGenerator
if (PRECOMPILE_TRSM_DTRSM OR PRECOMPILE_TRSM_STRSM)


ExternalProject_Add( OCLBinaryGenerator
	URL "${CMAKE_SOURCE_DIR}/library/tools/OCLBinaryGenerator"
	CMAKE_ARGS -DOPENCL_LIBRARIES=${OPENCL_LIBRARIES} -DOPENCL_INCLUDE_DIRS=${OPENCL_INCLUDE_DIRS}
	INSTALL_COMMAND ""
)
ExternalProject_Get_Property( OCLBinaryGenerator binary_dir )
message(STATUS "OCLBinaryGenerator binary_dir =${binary_dir}")
set( OCLBinaryGeneratorBinaryDir "${binary_dir}/staging" )

# OCLBinaryGenerator requires at least three inputs
# 1, path to the kernel file
# 2, file name
# 3, output directory
# 4, [optional] compiler flags
# 5, [optional] trageted hardware. If this is not supplied OCLBinaryGenerator will generate binary for the first device on system
set( OCL_COMPILER_FLAGS " ")
if( OPENCL_VERSION STREQUAL "2.0")
    set( OCL_COMPILER_FLAGS "-cl-std=CL2.0")
endif()

add_custom_target( OCLBinaryGenerator_GEN )
add_custom_command(TARGET OCLBinaryGenerator_GEN
                   PRE_BUILD
				   COMMAND ${CMAKE_COMMAND} -DOCLBinaryGeneratorBinaryDir=${OCLBinaryGeneratorBinaryDir} -DSOURCE_DIR=${CMAKE_SOURCE_DIR} -DBINARY_DIR=${CMAKE_BINARY_DIR} -DOCL_COMPILER_FLAGS=${OCL_COMPILER_FLAGS}
				   -P "${CMAKE_SOURCE_DIR}/library/OCLBinaryGenerator.cmake"
				   )
add_dependencies( OCLBinaryGenerator_GEN OCLBinaryGenerator )

endif()

# if offline compilation is not chosen, bingen should not be built
if(OPENCL_OFFLINE_BUILD_TAHITI_KERNEL OR OPENCL_OFFLINE_BUILD_HAWAII_KERNEL OR OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL)
	ExternalProject_Add( bingen
		URL "${CMAKE_SOURCE_DIR}/library/tools/bingen"
		CMAKE_ARGS -DOPENCL_LIBRARIES=${OPENCL_LIBRARIES} -DOPENCL_INCLUDE_DIRS=${OPENCL_INCLUDE_DIRS}
		INSTALL_COMMAND ""
	)
endif()

message(STATUS "OPENCL_VERSION = ${OPENCL_VERSION}")
#if( OPENCL_VERSION STREQUAL "2.0")
#	if(EXISTS ${CMAKE_SOURCE_DIR}/flags.txt)
#		MESSAGE(STATUS "flags.txt found. will load AMD_OPENCL_BUILD_OPTIONS_APPEND from it.")
#		set (LOAD_CL_FLAGS TRUE)
#		file (STRINGS "${CMAKE_SOURCE_DIR}/flags.txt" OPENCL_FLAGS)
#		MESSAGE(STATUS "OCLFLAGS: ${OPENCL_FLAGS}")
#		string(REPLACE "OCL " "OCL;" OPENCL_FLAGS_REPLACED ${OPENCL_FLAGS})
#		list(GET OPENCL_FLAGS_REPLACED 1 OPENCL_FLAGS_REPLACED_1)#flags for TAHITI
#		list(GET OPENCL_FLAGS_REPLACED 3 OPENCL_FLAGS_REPLACED_3)#flags for HAWAII 1
#		list(GET OPENCL_FLAGS_REPLACED 5 OPENCL_FLAGS_REPLACED_5)#flags for HAWAII 2
#		list(GET OPENCL_FLAGS_REPLACED 7 OPENCL_FLAGS_REPLACED_7)#flags for BONAIRE
#		#MESSAGE("${OPENCL_FLAGS_REPLACED_7}")
#	elseif(EXISTS ${CMAKE_SOURCE_DIR}/flags_public.txt)
#		MESSAGE(STATUS "flags_public.txt found. will load AMD_OPENCL_BUILD_OPTIONS_APPEND from it.")
#		set (LOAD_CL_FLAGS TRUE)
#		file (STRINGS "${CMAKE_SOURCE_DIR}/flags_public.txt" OPENCL_FLAGS)
#		MESSAGE(STATUS "OCLFLAGS: ${OPENCL_FLAGS}")
#		string(REPLACE "OCL " "OCL;" OPENCL_FLAGS_REPLACED ${OPENCL_FLAGS})
#		list(GET OPENCL_FLAGS_REPLACED 1 OPENCL_FLAGS_REPLACED_1)#flags for TAHITI
#		list(GET OPENCL_FLAGS_REPLACED 3 OPENCL_FLAGS_REPLACED_3)#flags for HAWAII 1
#		list(GET OPENCL_FLAGS_REPLACED 5 OPENCL_FLAGS_REPLACED_5)#flags for HAWAII 2
#		list(GET OPENCL_FLAGS_REPLACED 7 OPENCL_FLAGS_REPLACED_7)#flags for BONAIRE
#	else()
#		MESSAGE(STATUS "flags.txt not found. will use the default flags.")
#		set (LOAD_CL_FLAGS FALSE)
#	endif()
#else()
#	MESSAGE(STATUS "loading of compiler flags requires OpenCL 2.0. will use default flags.")
#	set (LOAD_CL_FLAGS FALSE)
  #endif()
set (LOAD_CL_FLAGS FALSE)

#set( bingenBinaryDir "${CMAKE_BINARY_DIR}/library/tools/bingen/staging" )
# if offline compilation is not chosen, bingen should not be built
if(OPENCL_OFFLINE_BUILD_TAHITI_KERNEL OR OPENCL_OFFLINE_BUILD_HAWAII_KERNEL OR OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL)
	ExternalProject_Get_Property( bingen binary_dir )

set( bingenBinaryDir "" )
if( CMAKE_COMPILER_IS_GNUCXX )
    set( bingenBinaryDir "${binary_dir}/staging" )
else()
    set( bingenBinaryDir "${binary_dir}/staging" )
#    set( bingenBinaryDir "${binary_dir}/${CMAKE_CFG_INTDIR}" )
endif()

if (LOAD_CL_FLAGS)
add_custom_target( GEN_CLBIN )
add_custom_command(TARGET GEN_CLBIN
                   PRE_BUILD
				   COMMAND ${CMAKE_COMMAND} -DbingenBinaryDir=${bingenBinaryDir} -DCLTEMPLATE_PATH="${CMAKE_SOURCE_DIR}/library/blas/gens/clTemplates"
	               -DLOAD_CL_FLAGS=${LOAD_CL_FLAGS} -DTAHITI_FLAG=${OPENCL_FLAGS_REPLACED_1} -DHAWAII1_FLAG=${OPENCL_FLAGS_REPLACED_3} -DHAWAII2_FLAG=${OPENCL_FLAGS_REPLACED_5} -DBONAIRE_FLAG=${OPENCL_FLAGS_REPLACED_7}
				   -DENV_PATH=${ENV_PATH} -DOPENCL_OFFLINE_BUILD_HAWAII_KERNEL=${OPENCL_OFFLINE_BUILD_HAWAII_KERNEL} -DOPENCL_OFFLINE_BUILD_BONAIRE_KERNEL=${OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL}
				   -DOPENCL_OFFLINE_BUILD_TAHITI_KERNEL=${OPENCL_OFFLINE_BUILD_TAHITI_KERNEL}
				   -P "${CMAKE_SOURCE_DIR}/library/bingen.cmake"
				   )
add_dependencies( GEN_CLBIN bingen )
else()
add_custom_target( GEN_CLBIN )
add_custom_command(TARGET GEN_CLBIN
                   PRE_BUILD
				   COMMAND ${CMAKE_COMMAND} -DbingenBinaryDir=${bingenBinaryDir} -DCLTEMPLATE_PATH="${CMAKE_SOURCE_DIR}/library/blas/gens/clTemplates"
				   -DOPENCL_OFFLINE_BUILD_HAWAII_KERNEL=${OPENCL_OFFLINE_BUILD_HAWAII_KERNEL} -DOPENCL_OFFLINE_BUILD_BONAIRE_KERNEL=${OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL}
				   -DOPENCL_OFFLINE_BUILD_TAHITI_KERNEL=${OPENCL_OFFLINE_BUILD_TAHITI_KERNEL}
				   -P "${CMAKE_SOURCE_DIR}/library/bingen.cmake"
				   )
add_dependencies( GEN_CLBIN bingen )
endif()
endif()#if(OPENCL_OFFLINE_BUILD_TAHITI_KERNEL OR OPENCL_OFFLINE_BUILD_HAWAII_KERNEL OR OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL)

ExternalProject_Get_Property( tplgen binary_dir )

set( tplgenBinaryDir "" )
if( CMAKE_COMPILER_IS_GNUCXX )
    set( tplgenBinaryDir ${binary_dir} )
else()
    set( tplgenBinaryDir "${binary_dir}/${CMAKE_CFG_INTDIR}" )
endif()

add_custom_target( GENERATE_CLT
    COMMAND ${tplgenBinaryDir}/tplgen -o ${clBLAS_BINARY_DIR}/include -i ${CMAKE_SOURCE_DIR}/library/blas/gens/clTemplates/ ${SRC_CL_TEMPLATES}
    COMMAND ${tplgenBinaryDir}/tplgen -o ${clBLAS_BINARY_DIR}/include -i ${bingenBinaryDir}/ ${SRC_CL_TEMPLATES_GEN}
    #WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/library/blas/gens/clTemplates
	WORKING_DIRECTORY ${bingenBinaryDir}
)

#add_dependencies( tplgen GEN_CLBIN )
add_dependencies( GENERATE_CLT tplgen )

if( CMAKE_COMPILER_IS_GNUCC )
    configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/clBLAS.pc.in
                    ${CMAKE_CURRENT_BINARY_DIR}/clBLAS.pc @ONLY )

    install( FILES ${CMAKE_CURRENT_BINARY_DIR}/clBLAS.pc
             DESTINATION lib${SUFFIX_LIB}/pkgconfig )
endif( )

# clBLAS to depend on AutoGemm

if ( ${PRECOMPILE_GEMM_ACTIVE} )
  set( AUTOGEMM_PRECOMPILED_KERNELS_CONDITIONAL ${AUTOGEMM_PRECOMPILED_KERNELS} )
  MESSAGE( STATUS "clBLAS will depend on ${AUTOGEMM_PRECOMPILED_KERNELS}" )
else()
  set( AUTOGEMM_PRECOMPILED_KERNELS_CONDITIONAL )
  MESSAGE( STATUS "clBLAS will NOT depend on ${AUTOGEMM_PRECOMPILED_KERNELS}" )
endif()

set(CLBLAS_ALL_SOURCES
    ${CLBLAS_SOURCES}
    ${GLOBAL_HEADERS}
    ${SRC_BLAS_HEADERS}
    ${SRC_BLAS_GENS_HEADERS}
    ${AUTOGEMM_SRC}
    ${AUTOGEMM_HEADERS}
    ${AUTOGEMM_SCRIPTS}
    ${AUTOGEMM_PRECOMPILED_KERNELS_CONDITIONAL}
    ${USERGEMM_SRC}
    ${USERGEMM_HEADERS}
)
add_definitions(-DOPENCL_VERSION="${OPENCL_VERSION}")
add_library(clBLAS ${CLBLAS_ALL_SOURCES})
add_dependencies(clBLAS GENERATE_CLT)

function (add_target_definitions target)
  get_target_property(defs ${target} COMPILE_DEFINITIONS)
  if (defs MATCHES "NOTFOUND")
    set(defs "")
  endif ()
  foreach (def ${defs} ${ARGN})
    list(APPEND deflist ${def})
  endforeach ()
  set_target_properties(${target} PROPERTIES COMPILE_DEFINITIONS "${deflist}")
endfunction ()

add_target_definitions(clBLAS BUILDING_CLBLAS)

if (PRECOMPILE_TRSM_DTRSM OR PRECOMPILE_TRSM_STRSM)
add_dependencies(clBLAS OCLBinaryGenerator_GEN)
endif()

# AutoGemm needs compiler flag to utilize pre-compiled kernels
if ( ${PRECOMPILE_GEMM_ACTIVE} )
  set_target_properties(clBLAS PROPERTIES COMPILE_FLAGS -DAUTOGEMM_USE_PRE_COMPILED_KERNELS)
endif()

set_target_properties(clBLAS PROPERTIES VERSION ${clBLAS_VERSION})
set_target_properties(clBLAS PROPERTIES SOVERSION ${clBLAS_SOVERSION})
set_target_properties( clBLAS PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/staging" )
target_link_libraries(clBLAS ${OPENCL_LIBRARIES} ${MATH_LIBRARY} ${THREAD_LIBRARY})

# CPack configuration; include the executable into the package
install( TARGETS clBLAS
         EXPORT Library
         RUNTIME DESTINATION bin${SUFFIX_BIN}
         LIBRARY DESTINATION lib${SUFFIX_LIB}
		     ARCHIVE DESTINATION lib${SUFFIX_LIB}
		)

# For debug builds, include the debug runtimes into the package for testing on non-developer machines
set( CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP true )
set( CMAKE_INSTALL_DEBUG_LIBRARIES true )
set( CMAKE_INSTALL_DEBUG_LIBRARIES_ONLY true )

if( WIN32 )
    set( CLBLAS_RUNTIME_DESTINATION bin${SUFFIX_BIN} )
else( )
    set( CLBLAS_RUNTIME_DESTINATION lib${SUFFIX_LIB} )
endif( )

include( InstallRequiredSystemLibraries )

# Install necessary runtime files for debug builds
install(    PROGRAMS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
            CONFIGURATIONS Debug
            DESTINATION ${CLBLAS_RUNTIME_DESTINATION} )

# Install all *.pdb files for debug builds
install(    DIRECTORY ${PROJECT_BINARY_DIR}/staging/
            DESTINATION ${CLBLAS_RUNTIME_DESTINATION}
            OPTIONAL
            CONFIGURATIONS Debug
            FILES_MATCHING PATTERN "*.pdb" )

if(INSTALL_SRC)
# Install a snapshot of the source as it was for this build; useful for the .pdb's
    install(    DIRECTORY ${PROJECT_SOURCE_DIR}
                DESTINATION ${CLBLAS_RUNTIME_DESTINATION}
                OPTIONAL
                CONFIGURATIONS Debug )
endif()

