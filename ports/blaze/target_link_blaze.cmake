# Link the given target to BLAZE. It supports an optional BLAS argument, which can be set to use a BLAS library.
# Examples:
#     target_configure_blaze(main)
#     target_configure_blaze(main BLAS "OpenBLAS")
#     target_configure_blaze(main BLAS "MKL")
function(target_configure_blaze target)
  set(oneValueArgs BLAS)
  cmake_parse_arguments(
    LinkBlaze
    ""
    "${oneValueArgs}"
    ""
    ${ARGN}
  )

  if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64" OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL AMD64)
    set(BLAS_64Bit 1)
    # use inside openblas_common.h
    # fix for https://github.com/microsoft/vcpkg/issues/21072
    if(WIN32)
      target_compile_definitions(${target} PRIVATE OS_WINNT=1)
    endif()
    target_compile_definitions(${target} PRIVATE __64BIT__=1)
  else()
    set(BLAS_64Bit 0)
  endif()

  if(NOT
     "${LinkBlaze_BLAS}"
     STREQUAL
     ""
  )
    if("${LinkBlaze_BLAS}" STREQUAL "OpenBLAS")
      find_package(OpenBLAS REQUIRED)
      target_link_libraries(${target} PRIVATE OpenBLAS::OpenBLAS)

      # cblas.h
      find_path(CBLAS_DIR cblas.h)
      if(NOT
         "${CBLAS_DIR}"
         STREQUAL
         "NOTFOUND"
      )
        set(BLAZE_BLAS_INCLUDE_FILE ${CBLAS_DIR}/cblas.h)
      else()
        list(
          GET
          OpenBLAS_INCLUDE_DIR
          1
          ACTUAL_OpenBLAS_INCLUDE_DIR
        )
        set(BLAZE_BLAS_INCLUDE_FILE "${ACTUAL_OpenBLAS_INCLUDE_DIR}/cblas.h")
      endif()

      set(BLAZE_BLAS_MODE 1)
      set(BLAZE_BLAS_IS_PARALLEL 1)
      message(STATUS "Building Blaze with OpenBLAS.")
    elseif("${LinkBlaze_BLAS}" STREQUAL "MKL")
      find_package(MKL REQUIRED)
      target_link_libraries(${target} PRIVATE MKL::MKL)

      # cblas.h
      find_path(CBLAS_DIR cblas.h)
      if(NOT
         "${CBLAS_DIR}"
         STREQUAL
         "NOTFOUND"
      )
        message(STATUS "Found cblas.h in ${CBLAS_DIR}.")
        set(BLAZE_BLAS_INCLUDE_FILE ${CBLAS_DIR}/cblas.h)
      else()
        list(
          GET
          MKL_INCLUDE_DIR
          1
          ACTUAL_MKL_INCLUDE_DIR
        )
        set(BLAZE_BLAS_INCLUDE_FILE "${ACTUAL_MKL_INCLUDE_DIR}/cblas.h")
      endif()
      set(BLAZE_BLAS_MODE 1)
      set(BLAZE_BLAS_IS_PARALLEL 1)
      message(STATUS "Building Blaze with MKL.")
    else()
      message(
        WARNING
          "${LinkBlaze_BLAS} is not a supported. You should configure the BLAS library yourself. The Supported BLAS libraries are: OpenBLAS, MKL"
      )
      return()
    endif()
  else()
    message(STATUS "Building Blaze without BLAS.")
    set(BLAZE_BLAS_MODE 0)
    set(BLAZE_BLAS_IS_PARALLEL 0)
  endif()

  target_compile_definitions(
    ${target}
    PRIVATE
      BLAZE_BLAS_MODE=${BLAZE_BLAS_MODE} # Enable BLAS
      BLAZE_BLAS_INCLUDE_FILE="${BLAZE_BLAS_INCLUDE_FILE}" # BLAS lib (the Blaze's default is <cblas.h>)
      BLAZE_BLAS_IS_64BIT=${BLAS_64Bit} # 64Bit BLAS
      BLAZE_BLAS_IS_PARALLEL=${BLAZE_BLAS_IS_PARALLEL} # If the BLAS itself is parallel, disable the Blaze's internal parallelization
      BLAZE_USE_VECTORIZATION=1 # Vectorization
  )
endfunction()
