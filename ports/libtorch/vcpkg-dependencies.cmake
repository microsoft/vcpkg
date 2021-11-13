# caffe2/core/macros.h.in
set(CAFFE2_USE_GOOGLE_GLOG 1)
set(CAFFE2_USE_LITE_PROTO 0)
# set(CAFFE2_FORCE_FALLBACK_CUDA_MPI 0)

# aten/src/ATen/Config.h.in
set(AT_POCKETFFT_ENABLED 0)
set(AT_MKL_ENABLED 0)
set(AT_FFTW_ENABLED 0)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
if(BUILD_PYTHON)
    find_package(Python3 REQUIRED COMPONENTS Development)
    list(APPEND Caffe2_DEPENDENCY_LIBS Python3::Python)
    if(USE_NUMPY)
        find_package(Python3 COMPONENTS Development NumPy)
        if(NOT TARGET Python3::NumPy)
            message(WARNING "Failed to find Python3::NumPy")
        else()
            list(APPEND Caffe2_DEPENDENCY_LIBS Python3::NumPy)
        endif()
    endif()
    find_package(pybind11 CONFIG REQUIRED)
    list(APPEND Caffe2_DEPENDENCY_LIBS pybind11::pybind11)
endif()
set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})

find_path(FP16_INCLUDE_DIRS "fp16.h")
find_path(PSIMD_INCLUDE_DIRS "psimd.h")
find_path(FXDIV_INCLUDE_DIRS "fxdiv.h")

find_package(gemmlowp CONFIG REQUIRED) # gemmlowp::gemmlowp
find_package(gflags CONFIG REQUIRED) # gflags::gflags
find_package(glog CONFIG REQUIRED) # glog::glog
find_package(unofficial-cpuinfo CONFIG REQUIRED) # cpuinfo::clog cpuinfo::cpuinfo
find_package(unofficial-pthreadpool CONFIG REQUIRED) # unofficial::pthreadpool
list(APPEND Caffe2_DEPENDENCY_LIBS
  gemmlowp::gemmlowp gflags::gflags glog::glog
  unofficial::cpuinfo::clog unofficial::cpuinfo::cpuinfo unofficial::pthreadpool
)
link_directories(
  $<$<CONFIG:Debug>:${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib>
  $<$<CONFIG:Release>:${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib>
)

set(USE_PTHREADPOOL 1)
set(USE_INTERNAL_PTHREADPOOL_IMPL 0)
add_compile_definitions(USE_PTHREADPOOL)

find_package(fmt CONFIG REQUIRED) # fmt::fmt-header-only
list(APPEND Caffe2_DEPENDENCY_LIBS fmt::fmt-header-only)

if(BLAS STREQUAL "Accelerate")
  set(WITH_BLAS "accelerate")
  find_package(BLAS REQUIRED) # cmake/Modules/FindBLAS.cmake
  find_package(LAPACK REQUIRED) # cmake/Modules/FindLAPACK.cmake
  set(USE_LAPACK 1)
  list(APPEND Caffe2_PRIVATE_DEPENDENCY_LIBS ${LAPACK_LIBRARIES})

elseif(BLAS STREQUAL "Eigen")
  find_package(Eigen3 CONFIG REQUIRED) # Eigen3::Eigen
  include_directories(SYSTEM ${EIGEN3_INCLUDE_DIR})
  list(APPEND Caffe2_DEPENDENCY_LIBS Eigen3::Eigen)
  set(CAFFE2_USE_EIGEN_FOR_BLAS 1) # see caff2/core/macros.h.in
  set(USE_LAPACK 0)

elseif(BLAS STREQUAL "MKL")
  if(USE_TBB)
    set(MKL_THREADING "TBB")
  else()
    set(MKL_THREADING "SEQ")
  endif()
  find_package(MKL REQUIRED)
  include(${CMAKE_CURRENT_LIST_DIR}/public/mkl.cmake)
  include_directories(AFTER SYSTEM ${MKL_INCLUDE_DIR})
  list(APPEND Caffe2_PUBLIC_DEPENDENCY_LIBS caffe2::mkl)
  set(WITH_BLAS "mkl")
  find_package(BLAS REQUIRED) # cmake/Modules/FindBLAS.cmake

endif()

if(USE_MKLDNN)
  find_package(MKLDNN REQUIRED) # BLAS::BLAS
  include(cmake/public/mkldnn.cmake)
  include_directories(AFTER SYSTEM ${MKLDNN_INCLUDE_DIR})
  list(APPEND Caffe2_PUBLIC_DEPENDENCY_LIBS caffe2::mkldnn)
endif()

if(USE_TBB)
  find_package(TBB CONFIG REQUIRED) # TBB::tbb
  list(APPEND Caffe2_DEPENDENCY_LIBS TBB::tbb)
endif()

if(USE_NNPACK)
  find_library(NNPACK_LIB NAME nnpack REQUIRED)
  list(APPEND Caffe2_DEPENDENCY_LIBS ${NNPACK_LIB})
  string(APPEND CMAKE_CXX_FLAGS " -DUSE_NNPACK")
endif()

if(USE_FBGEMM)
  find_package(asmjit CONFIG REQUIRED) # asmjit::asmjit (required by fbgemm)
  find_package(fbgemmLibrary CONFIG REQUIRED) # fbgemm
  list(APPEND Caffe2_DEPENDENCY_LIBS asmjit::asmjit fbgemm)
  if(USE_CUDA)
    # todo: fbgemm-gpu
  endif()
endif()

if(USE_LMDB)
  find_package(LMDB) # from cmake/Modules/FindLMDB.cmake
  if(LMDB_FOUND)
    list(APPEND Caffe2_DEPENDENCY_LIBS ${LMDB_LIBRARIES})
  else()
    find_package(lmdb CONFIG REQUIRED) # lmdb
    list(APPEND Caffe2_DEPENDENCY_LIBS lmdb)
  endif()
endif()

if(USE_LEVELDB)
  find_package(Snappy CONFIG REQUIRED) # Snappy::snappy
  list(APPEND Caffe2_DEPENDENCY_LIBS Snappy::snappy)
  find_package(LevelDB) # from cmake/Modules/FindLevelDB.cmake
  if(LevelDB_FOUND)
    list(APPEND Caffe2_DEPENDENCY_LIBS ${LevelDB_LIBRARIES})
  else()
    find_package(leveldb CONFIG REQUIRED) # leveldb::leveldb
    list(APPEND Caffe2_DEPENDENCY_LIBS leveldb::leveldb)
  endif()
endif()
 
if(USE_QNNPACK)
  find_library(QNNPACK_LIB NAME qnnpack REQUIRED)
  list(APPEND Caffe2_DEPENDENCY_LIBS ${QNNPACK_LIB})
endif()

if(USE_XNNPACK)
  find_package(xnnpack CONFIG REQUIRED) # unofficial::XNNPACK
  list(APPEND Caffe2_DEPENDENCY_LIBS unofficial::XNNPACK)
endif()
 
if(USE_ZSTD)
  find_package(zstd CONFIG REQUIRED) # zstd::libzstd_static
  list(APPEND Caffe2_DEPENDENCY_LIBS zstd::libzstd_static)
endif()

if(USE_SYSTEM_ONNX)
  find_package(ONNX CONFIG REQUIRED) # onnx onnx_proto onnxifi_loader
  find_package(ONNXOptimizer CONFIG REQUIRED) # onnx_optimizer
  list(APPEND Caffe2_DEPENDENCY_LIBS onnx onnx_proto onnxifi_loader onnx_optimizer)
  if(ONNX_ML)
    add_compile_definitions(ONNX_ML=1)
  endif()
endif()

if(USE_CUDA)
  find_package(CUDA  10.1 REQUIRED) # https://cmake.org/cmake/help/latest/module/FindCUDA.html
  find_package(CUDNN 8.0  REQUIRED) # CuDNN::CuDNN
  cuda_select_nvcc_arch_flags(ARCH_FLAGS 7.5 7.5PTX)
  set(CUDA_NVCC_FLAGS ${ARCH_FLAGS})
  list(APPEND CUDA_NVCC_FLAGS    # check TORCH_NVCC_FLAGS in this project
    -D__CUDA_NO_HALF_OPERATORS__ # see https://github.com/torch/cutorch/issues/797
  )
  set(CAFFE2_USE_CUDNN 1)
  include(cmake/public/cuda.cmake)
  list(APPEND Caffe2_DEPENDENCY_LIBS CuDNN::CuDNN)
endif()

if(USE_NUMA) # Linux package 'libnuma-dev'
  find_package(Numa REQUIRED)
  include_directories(SYSTEM ${Numa_INCLUDE_DIR})
  list(APPEND Caffe2_DEPENDENCY_LIBS ${Numa_LIBRARIES})
endif()

if(USE_GLOO)
  find_package(Gloo CONFIG REQUIRED)
  list(APPEND Caffe2_DEPENDENCY_LIBS gloo)
endif()

if(USE_VULKAN)
  find_package(Vulkan REQUIRED)
endif()

if(USE_TENSORPIPE)
  find_package(unofficial-libuv CONFIG REQUIRED) # unofficial::libuv::libuv
  find_package(tensorpipe CONFIG REQUIRED) # tensorpipe
  list(APPEND Caffe2_DEPENDENCY_LIBS unofficial::libuv::libuv tensorpipe)
endif()

if(USE_MPI)
  find_package(MPI REQUIRED) # API package: libopenmpi-dev
  if(NOT MPI_CXX_FOUND)
    message(FATAL_ERROR "Failed to find MPI_CXX")
  endif()
  include_directories(SYSTEM ${MPI_CXX_INCLUDE_PATH})
  list(APPEND Caffe2_DEPENDENCY_LIBS ${MPI_CXX_LIBRARIES})
  list(APPEND CMAKE_EXE_LINKER_FLAGS ${MPI_CXX_LINK_FLAGS})

  find_program(OMPI_INFO NAMES ompi_info HINTS ${MPI_CXX_LIBRARIES}/../bin)
  if(OMPI_INFO)
    execute_process(COMMAND ${OMPI_INFO} OUTPUT_VARIABLE _output)
    if(_output MATCHES "smcuda")
      message(STATUS "Found OpenMPI with CUDA support built.")
    else()
      message(WARNING "OpenMPI found, but it is not built with CUDA support.")
      set(CAFFE2_FORCE_FALLBACK_CUDA_MPI 1)
    endif()
  endif()
endif()

if(USE_OPENCV)
  find_package(OpenCV 4 COMPONENTS core highgui imgproc imgcodecs optflow videoio video)
  if(NOT OpenCV_FOUND)
    find_package(OpenCV 3 REQUIRED COMPONENTS core highgui imgproc imgcodecs videoio video)
  endif()
  include_directories(SYSTEM ${OpenCV_INCLUDE_DIRS})
  list(APPEND Caffe2_DEPENDENCY_LIBS ${OpenCV_LIBS})
  if(MSVC AND USE_CUDA)
    list(APPEND Caffe2_CUDA_DEPENDENCY_LIBS ${OpenCV_LIBS})
  endif()
endif()

if(USE_OPENCL)
  find_package(OpenCL REQUIRED)
  include_directories(SYSTEM ${OpenCL_INCLUDE_DIRS})
  include_directories(${CMAKE_CURRENT_LIST_DIR}/../caffe2/contrib/opencl)
  list(APPEND Caffe2_DEPENDENCY_LIBS ${OpenCL_LIBRARIES})
endif()
