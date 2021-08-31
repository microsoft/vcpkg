  
# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindBLAS
--------

Find Basic Linear Algebra Subprograms (BLAS) library

This module finds an installed Fortran library that implements the
`BLAS linear-algebra interface`_.

At least one of the ``C``, ``CXX``, or ``Fortran`` languages must be enabled.

.. _`BLAS linear-algebra interface`: http://www.netlib.org/blas/

Input Variables
^^^^^^^^^^^^^^^

The following variables may be set to influence this module's behavior:

``BLA_STATIC``
  if ``ON`` use static linkage

``BLA_VENDOR``
  Set to one of the :ref:`BLAS/LAPACK Vendors` to search for BLAS only
  from the specified vendor.  If not set, all vendors are considered.

``BLA_F95``
  if ``ON`` tries to find the BLAS95 interfaces

``BLA_PREFER_PKGCONFIG``
  .. versionadded:: 3.11

  if set ``pkg-config`` will be used to search for a BLAS library first
  and if one is found that is preferred

Imported targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

``BLAS::BLAS``
  .. versionadded:: 3.18

  The libraries to use for BLAS, if found.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

``BLAS_FOUND``
  library implementing the BLAS interface is found
``BLAS_LINKER_FLAGS``
  uncached list of required linker flags (excluding ``-l`` and ``-L``).
``BLAS_LIBRARIES``
  uncached list of libraries (using full path name) to link against
  to use BLAS (may be empty if compiler implicitly links BLAS)
``BLAS95_LIBRARIES``
  uncached list of libraries (using full path name) to link against
  to use BLAS95 interface
``BLAS95_FOUND``
  library implementing the BLAS95 interface is found

.. _`BLAS/LAPACK Vendors`:

BLAS/LAPACK Vendors
^^^^^^^^^^^^^^^^^^^

``Generic``
  Generic reference implementation

``ACML``, ``ACML_MP``, ``ACML_GPU``
  AMD Core Math Library

``Apple``, ``NAS``
  Apple BLAS (Accelerate), and Apple NAS (vecLib)

``Arm``, ``Arm_mp``, ``Arm_ilp64``, ``Arm_ilp64_mp``
  .. versionadded:: 3.18

  Arm Performance Libraries

``ATLAS``
  Automatically Tuned Linear Algebra Software

``CXML``, ``DXML``
  Compaq/Digital Extended Math Library

``EML``, ``EML_mt``
  .. versionadded:: 3.20

  Elbrus Math Library

``FLAME``
  .. versionadded:: 3.11

  BLIS Framework

``FlexiBLAS``
  .. versionadded:: 3.19

``Fujitsu_SSL2``, ``Fujitsu_SSL2BLAMP``
  .. versionadded:: 3.20

  Fujitsu SSL2 serial and parallel blas/lapack

``Goto``
  GotoBLAS

``IBMESSL``
  IBM Engineering and Scientific Subroutine Library

``Intel``
  Intel MKL 32 bit and 64 bit obsolete versions

``Intel10_32``
  Intel MKL v10 32 bit, threaded code

``Intel10_64lp``
  Intel MKL v10+ 64 bit, threaded code, lp64 model

``Intel10_64lp_seq``
  Intel MKL v10+ 64 bit, sequential code, lp64 model

``Intel10_64ilp``
  .. versionadded:: 3.13

  Intel MKL v10+ 64 bit, threaded code, ilp64 model

``Intel10_64ilp_seq``
  .. versionadded:: 3.13

  Intel MKL v10+ 64 bit, sequential code, ilp64 model

``Intel10_64_dyn``
  .. versionadded:: 3.17

  Intel MKL v10+ 64 bit, single dynamic library

``NVHPC``
  .. versionadded:: 3.21

  NVIDIA HPC SDK

``OpenBLAS``
  .. versionadded:: 3.6

``PhiPACK``
  Portable High Performance ANSI C (PHiPAC)

``SCSL``, ``SCSL_mp``
  Scientific Computing Software Library

``SGIMATH``
  SGI Scientific Mathematical Library

``SunPerf``
  Sun Performance Library

.. _`Intel MKL`:

Intel MKL
^^^^^^^^^

To use the Intel MKL implementation of BLAS, a project must enable at least
one of the ``C`` or ``CXX`` languages.  Set ``BLA_VENDOR`` to an Intel MKL
variant either on the command-line as ``-DBLA_VENDOR=Intel10_64lp`` or in
project code:

.. code-block:: cmake

  set(BLA_VENDOR Intel10_64lp)
  find_package(BLAS)

In order to build a project using Intel MKL, and end user must first
establish an Intel MKL environment:

Intel oneAPI
  Source the full Intel environment script:

  .. code-block:: shell

    . /opt/intel/oneapi/setvars.sh

  Or, source the MKL component environment script:

  .. code-block:: shell

    . /opt/intel/oneapi/mkl/latest/env/vars.sh

Intel Classic
  Source the full Intel environment script:

  .. code-block:: shell

    . /opt/intel/bin/compilervars.sh intel64

  Or, source the MKL component environment script:

  .. code-block:: shell

    . /opt/intel/mkl/bin/mklvars.sh intel64

The above environment scripts set the ``MKLROOT`` environment variable
to the top of the MKL installation.  They also add the location of the
runtime libraries to the dynamic library loader environment variable for
your platform (e.g. ``LD_LIBRARY_PATH``).  This is necessary for programs
linked against MKL to run.

.. note::

  As of Intel oneAPI 2021.2, loading only the MKL component does not
  make all of its dependencies available.  In particular, the ``iomp5``
  library must be available separately, or provided by also loading
  the compiler component environment:

  .. code-block:: shell

    . /opt/intel/oneapi/compiler/latest/env/vars.sh

#]=======================================================================]

# The approach follows that of the ``autoconf`` macro file, ``acx_blas.m4``
# (distributed at http://ac-archive.sourceforge.net/ac-archive/acx_blas.html).

# Check the language being used
if(NOT (CMAKE_C_COMPILER_LOADED OR CMAKE_CXX_COMPILER_LOADED OR CMAKE_Fortran_COMPILER_LOADED))
  if(BLAS_FIND_REQUIRED)
    message(FATAL_ERROR "FindBLAS requires Fortran, C, or C++ to be enabled.")
  else()
    message(STATUS "Looking for BLAS... - NOT found (Unsupported languages)")
    return()
  endif()
endif()

function(_add_blas_target)
  if(BLAS_FOUND AND NOT TARGET BLAS::BLAS)
    add_library(BLAS::BLAS INTERFACE IMPORTED)
    if(BLAS_LIBRARIES)
      set_target_properties(BLAS::BLAS PROPERTIES
        INTERFACE_LINK_LIBRARIES "${BLAS_LIBRARIES}"
      )
    endif()
    if(BLAS_LINKER_FLAGS)
      set_target_properties(BLAS::BLAS PROPERTIES
        INTERFACE_LINK_OPTIONS "${BLAS_LINKER_FLAGS}"
      )
    endif()
  endif()
endfunction()

if(CMAKE_Fortran_COMPILER_LOADED)
  include(${CMAKE_ROOT}/Modules/CheckFortranFunctionExists.cmake)
else()
  include(${CMAKE_ROOT}/Modules/CheckFunctionExists.cmake)
endif()
include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)

if(BLA_PREFER_PKGCONFIG)
  find_package(PkgConfig)
  pkg_check_modules(PKGC_BLAS blas)
  if(PKGC_BLAS_FOUND)
    set(BLAS_FOUND ${PKGC_BLAS_FOUND})
    set(BLAS_LIBRARIES "${PKGC_BLAS_LINK_LIBRARIES}")
    _add_blas_target()
    return()
  endif()
endif()

# TODO: move this stuff to a separate module

function(CHECK_BLAS_LIBRARIES LIBRARIES _prefix _name _flags _list _deps _addlibdir _subdirs)
  # This function checks for the existence of the combination of libraries
  # given by _list.  If the combination is found, this checks whether can link
  # against that library combination using the name of a routine given by _name
  # using the linker flags given by _flags.  If the combination of libraries is
  # found and passes the link test, ${LIBRARIES} is set to the list of complete
  # library paths that have been found.  Otherwise, ${LIBRARIES} is set to FALSE.

  set(_libraries_work TRUE)
  set(_libraries)
  set(_combined_name)

  if(BLA_STATIC)
    if(WIN32)
      set(CMAKE_FIND_LIBRARY_SUFFIXES .lib ${CMAKE_FIND_LIBRARY_SUFFIXES})
    else()
      set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif()
  else()
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
      # for ubuntu's libblas3gf and liblapack3gf packages
      set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES} .so.3gf)
    endif()
  endif()

  set(_extaddlibdir "${_addlibdir}")
  if(WIN32)
    list(APPEND _extaddlibdir ENV LIB)
  elseif(APPLE)
    list(APPEND _extaddlibdir ENV DYLD_LIBRARY_PATH)
  else()
    list(APPEND _extaddlibdir ENV LD_LIBRARY_PATH)
  endif()
  list(APPEND _extaddlibdir "${CMAKE_C_IMPLICIT_LINK_DIRECTORIES}")

  foreach(_library ${_list})
    if(_library MATCHES "^-")
      # Respect linker flags as-is (required by MKL)
      list(APPEND _libraries "${_library}")
    else()
      string(REGEX REPLACE "[^A-Za-z0-9]" "_" _lib_var "${_library}")
      set(_combined_name ${_combined_name}_${_lib_var})
      if(NOT "${_deps}" STREQUAL "")
        set(_combined_name ${_combined_name}_deps)
      endif()
      if(_libraries_work)
        find_library(${_prefix}_${_lib_var}_LIBRARY
          NAMES ${_library}
          NAMES_PER_DIR
          PATHS ${_extaddlibdir}
          PATH_SUFFIXES ${_subdirs}
        )
        mark_as_advanced(${_prefix}_${_lib_var}_LIBRARY)
        list(APPEND _libraries ${${_prefix}_${_lib_var}_LIBRARY})
        set(_libraries_work ${${_prefix}_${_lib_var}_LIBRARY})
      endif()
    endif()
  endforeach()

  foreach(_flag ${_flags})
    string(REGEX REPLACE "[^A-Za-z0-9]" "_" _flag_var "${_flag}")
    set(_combined_name ${_combined_name}_${_flag_var})
  endforeach()
  if(_libraries_work)
    # Test this combination of libraries.
    set(CMAKE_REQUIRED_LIBRARIES ${_flags} ${_libraries} ${_deps})
    set(CMAKE_REQUIRED_QUIET ${BLAS_FIND_QUIETLY})
    if(CMAKE_Fortran_COMPILER_LOADED)
      check_fortran_function_exists("${_name}" ${_prefix}${_combined_name}_WORKS)
    else()
      check_function_exists("${_name}_" ${_prefix}${_combined_name}_WORKS)
    endif()
    set(CMAKE_REQUIRED_LIBRARIES)
    set(_libraries_work ${${_prefix}${_combined_name}_WORKS})
  endif()

  if(_libraries_work)
    if("${_list}" STREQUAL "")
      set(_libraries "${LIBRARIES}-PLACEHOLDER-FOR-EMPTY-LIBRARIES")
    else()
      list(APPEND _libraries ${_deps})
    endif()
  else()
    set(_libraries FALSE)
  endif()
  set(${LIBRARIES} "${_libraries}" PARENT_SCOPE)
endfunction()

set(BLAS_LINKER_FLAGS)
set(BLAS_LIBRARIES)
set(BLAS95_LIBRARIES)
set(_blas_fphsa_req_var BLAS_LIBRARIES)
if(NOT $ENV{BLA_VENDOR} STREQUAL "")
  set(BLA_VENDOR $ENV{BLA_VENDOR})
else()
  if(NOT BLA_VENDOR)
    set(BLA_VENDOR "All")
  endif()
endif()

# Implicitly linked BLAS libraries?
if(BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      ""
      ""
      ""
      ""
      )
  endif()
  if(BLAS_WORKS)
    # Give a more helpful "found" message
    set(BLAS_WORKS "implicitly linked")
    set(_blas_fphsa_req_var BLAS_WORKS)
  endif()
endif()

# BLAS in the Intel MKL 10+ library?
if(BLA_VENDOR MATCHES "Intel" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    if(CMAKE_C_COMPILER_LOADED OR CMAKE_CXX_COMPILER_LOADED)
      # System-specific settings
      if(WIN32)
        if(BLA_STATIC)
          set(BLAS_mkl_DLL_SUFFIX "")
        else()
          set(BLAS_mkl_DLL_SUFFIX "_dll")
        endif()
      else()
        if(BLA_STATIC)
          set(BLAS_mkl_START_GROUP "-Wl,--start-group")
          set(BLAS_mkl_END_GROUP "-Wl,--end-group")
        else()
          set(BLAS_mkl_START_GROUP "")
          set(BLAS_mkl_END_GROUP "")
        endif()
        # Switch to GNU Fortran support layer if needed (but not on Apple, where MKL does not provide it)
        if(CMAKE_Fortran_COMPILER_LOADED AND CMAKE_Fortran_COMPILER_ID STREQUAL "GNU" AND NOT APPLE)
            set(BLAS_mkl_INTFACE "gf")
            set(BLAS_mkl_THREADING "gnu")
            set(BLAS_mkl_OMP "gomp")
        else()
            set(BLAS_mkl_INTFACE "intel")
            set(BLAS_mkl_THREADING "intel")
            set(BLAS_mkl_OMP "iomp5")
        endif()
        set(BLAS_mkl_LM "-lm")
        set(BLAS_mkl_LDL "-ldl")
      endif()

      if(BLAS_FIND_QUIETLY OR NOT BLAS_FIND_REQUIRED)
        find_package(Threads)
      else()
        find_package(Threads REQUIRED)
      endif()

      if(BLA_VENDOR MATCHES "_64ilp")
        set(BLAS_mkl_ILP_MODE "ilp64")
      else()
        set(BLAS_mkl_ILP_MODE "lp64")
      endif()

      set(BLAS_SEARCH_LIBS "")

      if(BLA_F95)
        set(BLAS_mkl_SEARCH_SYMBOL "sgemm_f95")
        set(_BLAS_LIBRARIES BLAS95_LIBRARIES)
        if(WIN32)
          # Find the main file (32-bit or 64-bit)
          set(BLAS_SEARCH_LIBS_WIN_MAIN "")
          if(BLA_VENDOR STREQUAL "Intel10_32" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS_WIN_MAIN
              "mkl_blas95${BLAS_mkl_DLL_SUFFIX} mkl_intel_c${BLAS_mkl_DLL_SUFFIX}")
          endif()

          if(BLA_VENDOR MATCHES "^Intel10_64i?lp" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS_WIN_MAIN
              "mkl_blas95_${BLAS_mkl_ILP_MODE}${BLAS_mkl_DLL_SUFFIX} mkl_intel_${BLAS_mkl_ILP_MODE}${BLAS_mkl_DLL_SUFFIX}")
          endif()

          # Add threading/sequential libs
          set(BLAS_SEARCH_LIBS_WIN_THREAD "")
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp$" OR BLA_VENDOR STREQUAL "All")
            # old version
            list(APPEND BLAS_SEARCH_LIBS_WIN_THREAD
              "libguide40 mkl_intel_thread${BLAS_mkl_DLL_SUFFIX}")
            # mkl >= 10.3
            list(APPEND BLAS_SEARCH_LIBS_WIN_THREAD
              "libiomp5md mkl_intel_thread${BLAS_mkl_DLL_SUFFIX}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp_seq$" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS_WIN_THREAD
              "mkl_sequential${BLAS_mkl_DLL_SUFFIX}")
          endif()

          # Cartesian product of the above
          foreach(MAIN ${BLAS_SEARCH_LIBS_WIN_MAIN})
            foreach(THREAD ${BLAS_SEARCH_LIBS_WIN_THREAD})
              list(APPEND BLAS_SEARCH_LIBS
                "${MAIN} ${THREAD} mkl_core${BLAS_mkl_DLL_SUFFIX}")
            endforeach()
          endforeach()
        else()
          if(BLA_VENDOR STREQUAL "Intel10_32" OR BLA_VENDOR STREQUAL "All")
            # old version
            list(APPEND BLAS_SEARCH_LIBS
              "mkl_blas95 mkl_${BLAS_mkl_INTFACE} mkl_${BLAS_mkl_THREADING}_thread mkl_core guide")

            # mkl >= 10.3
            list(APPEND BLAS_SEARCH_LIBS
              "${BLAS_mkl_START_GROUP} mkl_blas95 mkl_${BLAS_mkl_INTFACE} mkl_${BLAS_mkl_THREADING}_thread mkl_core ${BLAS_mkl_END_GROUP} ${BLAS_mkl_OMP}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp$" OR BLA_VENDOR STREQUAL "All")
            # old version
            list(APPEND BLAS_SEARCH_LIBS
              "mkl_blas95 mkl_${BLAS_mkl_INTFACE}_${BLAS_mkl_ILP_MODE} mkl_${BLAS_mkl_THREADING}_thread mkl_core guide")

            # mkl >= 10.3
            list(APPEND BLAS_SEARCH_LIBS
              "${BLAS_mkl_START_GROUP} mkl_blas95_${BLAS_mkl_ILP_MODE} mkl_${BLAS_mkl_INTFACE}_${BLAS_mkl_ILP_MODE} mkl_${BLAS_mkl_THREADING}_thread mkl_core ${BLAS_mkl_END_GROUP} ${BLAS_mkl_OMP}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp_seq$" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS
              "${BLAS_mkl_START_GROUP} mkl_blas95_${BLAS_mkl_ILP_MODE} mkl_${BLAS_mkl_INTFACE}_${BLAS_mkl_ILP_MODE} mkl_sequential mkl_core ${BLAS_mkl_END_GROUP}")
          endif()
        endif()
      else()
        set(BLAS_mkl_SEARCH_SYMBOL sgemm)
        set(_BLAS_LIBRARIES BLAS_LIBRARIES)
        if(WIN32)
          # Find the main file (32-bit or 64-bit)
          set(BLAS_SEARCH_LIBS_WIN_MAIN "")
          if(BLA_VENDOR STREQUAL "Intel10_32" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS_WIN_MAIN
              "mkl_intel_c${BLAS_mkl_DLL_SUFFIX}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS_WIN_MAIN
              "mkl_intel_${BLAS_mkl_ILP_MODE}${BLAS_mkl_DLL_SUFFIX}")
          endif()

          # Add threading/sequential libs
          set(BLAS_SEARCH_LIBS_WIN_THREAD "")
          if(BLA_VENDOR STREQUAL "Intel10_32" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS_WIN_THREAD
              "libiomp5md mkl_intel_thread${BLAS_mkl_DLL_SUFFIX}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp$" OR BLA_VENDOR STREQUAL "All")
            # old version
            list(APPEND BLAS_SEARCH_LIBS_WIN_THREAD
              "libguide40 mkl_intel_thread${BLAS_mkl_DLL_SUFFIX}")
            # mkl >= 10.3
            list(APPEND BLAS_SEARCH_LIBS_WIN_THREAD
              "libiomp5md mkl_intel_thread${BLAS_mkl_DLL_SUFFIX}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp_seq$" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS_WIN_THREAD
              "mkl_sequential${BLAS_mkl_DLL_SUFFIX}")
          endif()

          # Cartesian product of the above
          foreach(MAIN ${BLAS_SEARCH_LIBS_WIN_MAIN})
            foreach(THREAD ${BLAS_SEARCH_LIBS_WIN_THREAD})
              list(APPEND BLAS_SEARCH_LIBS
                "${MAIN} ${THREAD} mkl_core${BLAS_mkl_DLL_SUFFIX}")
            endforeach()
          endforeach()
        else()
          if(BLA_VENDOR STREQUAL "Intel10_32" OR BLA_VENDOR STREQUAL "All")
            # old version
            list(APPEND BLAS_SEARCH_LIBS
              "mkl_${BLAS_mkl_INTFACE} mkl_${BLAS_mkl_THREADING}_thread mkl_core guide")

            # mkl >= 10.3
            list(APPEND BLAS_SEARCH_LIBS
              "${BLAS_mkl_START_GROUP} mkl_${BLAS_mkl_INTFACE} mkl_${BLAS_mkl_THREADING}_thread mkl_core ${BLAS_mkl_END_GROUP} ${BLAS_mkl_OMP}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp$" OR BLA_VENDOR STREQUAL "All")
            # old version
            list(APPEND BLAS_SEARCH_LIBS
              "mkl_${BLAS_mkl_INTFACE}_${BLAS_mkl_ILP_MODE} mkl_${BLAS_mkl_THREADING}_thread mkl_core guide")

            # mkl >= 10.3
            list(APPEND BLAS_SEARCH_LIBS
              "${BLAS_mkl_START_GROUP} mkl_${BLAS_mkl_INTFACE}_${BLAS_mkl_ILP_MODE} mkl_${BLAS_mkl_THREADING}_thread mkl_core ${BLAS_mkl_END_GROUP} ${BLAS_mkl_OMP}")
          endif()
          if(BLA_VENDOR MATCHES "^Intel10_64i?lp_seq$" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS
              "${BLAS_mkl_START_GROUP} mkl_${BLAS_mkl_INTFACE}_${BLAS_mkl_ILP_MODE} mkl_sequential mkl_core ${BLAS_mkl_END_GROUP}")
          endif()

          #older versions of intel mkl libs
          if(BLA_VENDOR STREQUAL "Intel" OR BLA_VENDOR STREQUAL "All")
            list(APPEND BLAS_SEARCH_LIBS
              "mkl")
            list(APPEND BLAS_SEARCH_LIBS
              "mkl_ia32")
            list(APPEND BLAS_SEARCH_LIBS
              "mkl_em64t")
          endif()
        endif()
      endif()

      if(BLA_VENDOR MATCHES "^Intel10_64_dyn$" OR BLA_VENDOR STREQUAL "All")
        # mkl >= 10.3 with single dynamic library
        list(APPEND BLAS_SEARCH_LIBS
          "mkl_rt")
      endif()

      # MKL uses a multitude of partially platform-specific subdirectories:
      if(BLA_VENDOR STREQUAL "Intel10_32")
        set(BLAS_mkl_ARCH_NAME "ia32")
      else()
        set(BLAS_mkl_ARCH_NAME "intel64")
      endif()
      if(WIN32)
        set(BLAS_mkl_OS_NAME "win")
      elseif(APPLE)
        set(BLAS_mkl_OS_NAME "mac")
      else()
        set(BLAS_mkl_OS_NAME "lin")
      endif()
      if(DEFINED ENV{MKLROOT})
        file(TO_CMAKE_PATH "$ENV{MKLROOT}" BLAS_mkl_MKLROOT)
        # If MKLROOT points to the subdirectory 'mkl', use the parent directory instead
        # so we can better detect other relevant libraries in 'compiler' or 'tbb':
        get_filename_component(BLAS_mkl_MKLROOT_LAST_DIR "${BLAS_mkl_MKLROOT}" NAME)
        if(BLAS_mkl_MKLROOT_LAST_DIR STREQUAL "mkl")
            get_filename_component(BLAS_mkl_MKLROOT "${BLAS_mkl_MKLROOT}" DIRECTORY)
        endif()
      endif()
      set(BLAS_mkl_LIB_PATH_SUFFIXES
          "compiler/lib" "compiler/lib/${BLAS_mkl_ARCH_NAME}_${BLAS_mkl_OS_NAME}"
          "compiler/lib/${BLAS_mkl_ARCH_NAME}"
          "mkl/lib" "mkl/lib/${BLAS_mkl_ARCH_NAME}_${BLAS_mkl_OS_NAME}"
          "mkl/lib/${BLAS_mkl_ARCH_NAME}"
          "lib" "lib/${BLAS_mkl_ARCH_NAME}_${BLAS_mkl_OS_NAME}"
          "lib/${BLAS_mkl_ARCH_NAME}"
          )

      foreach(_search ${BLAS_SEARCH_LIBS})
        string(REPLACE " " ";" _search ${_search})
        if(NOT ${_BLAS_LIBRARIES})
          check_blas_libraries(
            ${_BLAS_LIBRARIES}
            BLAS
            ${BLAS_mkl_SEARCH_SYMBOL}
            ""
            "${_search}"
            "${CMAKE_THREAD_LIBS_INIT};${BLAS_mkl_LM};${BLAS_mkl_LDL}"
            "${BLAS_mkl_MKLROOT}"
            "${BLAS_mkl_LIB_PATH_SUFFIXES}"
            )
        endif()
      endforeach()

      unset(_search)
      unset(BLAS_mkl_ILP_MODE)
      unset(BLAS_mkl_INTFACE)
      unset(BLAS_mkl_THREADING)
      unset(BLAS_mkl_OMP)
      unset(BLAS_mkl_DLL_SUFFIX)
      unset(BLAS_mkl_LM)
      unset(BLAS_mkl_LDL)
      unset(BLAS_mkl_MKLROOT)
      unset(BLAS_mkl_MKLROOT_LAST_DIR)
      unset(BLAS_mkl_ARCH_NAME)
      unset(BLAS_mkl_OS_NAME)
      unset(BLAS_mkl_LIB_PATH_SUFFIXES)
    endif()
  endif()
endif()

if(BLA_F95)
  find_package_handle_standard_args(BLAS REQUIRED_VARS BLAS95_LIBRARIES)
  set(BLAS95_FOUND ${BLAS_FOUND})
  if(BLAS_FOUND)
    set(BLAS_LIBRARIES "${BLAS95_LIBRARIES}")
  endif()
endif()

# gotoblas? (http://www.tacc.utexas.edu/tacc-projects/gotoblas2)
if(BLA_VENDOR STREQUAL "Goto" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "goto2"
      ""
      ""
      ""
      )
  endif()
endif()

# FlexiBLAS? (http://www.mpi-magdeburg.mpg.de/mpcsc/software/FlexiBLAS/)
if(BLA_VENDOR STREQUAL "FlexiBLAS" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "flexiblas"
      ""
      ""
      ""
      )
  endif()
endif()

# OpenBLAS? (http://www.openblas.net)
if(BLA_VENDOR STREQUAL "OpenBLAS" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "openblas"
      ""
      ""
      ""
      )
  endif()
  if(NOT BLAS_LIBRARIES AND (CMAKE_C_COMPILER_LOADED OR CMAKE_CXX_COMPILER_LOADED))
    if(BLAS_FIND_QUIETLY OR NOT BLAS_FIND_REQUIRED)
      find_package(Threads)
    else()
      find_package(Threads REQUIRED)
    endif()
    set(_threadlibs "${CMAKE_THREAD_LIBS_INIT}")
    if(BLA_STATIC)
      if (CMAKE_C_COMPILER_LOADED)
        find_package(OpenMP COMPONENTS C)
        list(PREPEND _threadlibs "${OpenMP_C_LIBRARIES}")
      elseif(CMAKE_CXX_COMPILER_LOADED)
        find_package(OpenMP COMPONENTS CXX)
        list(PREPEND _threadlibs "${OpenMP_CXX_LIBRARIES}")
      endif()
    endif()
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "openblas"
      "${_threadlibs}"
      ""
      ""
      )
    unset(_threadlibs)
  endif()
endif()

# ArmPL blas library? (https://developer.arm.com/tools-and-software/server-and-hpc/compile/arm-compiler-for-linux/arm-performance-libraries)
if(BLA_VENDOR MATCHES "Arm" OR BLA_VENDOR STREQUAL "All")

   # Check for 64bit Integer support
   if(BLA_VENDOR MATCHES "_ilp64")
     set(_blas_armpl_lib "armpl_ilp64")
   else()
     set(_blas_armpl_lib "armpl_lp64")
   endif()

   # Check for OpenMP support, VIA BLA_VENDOR of Arm_mp or Arm_ipl64_mp
   if(BLA_VENDOR MATCHES "_mp")
     set(_blas_armpl_lib "${_blas_armpl_lib}_mp")
   endif()

   if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "${_blas_armpl_lib}"
      ""
      ""
      ""
      )
  endif()
  unset(_blas_armpl_lib)
endif()

# FLAME's blis library? (https://github.com/flame/blis)
if(BLA_VENDOR STREQUAL "FLAME" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "blis"
      ""
      ""
      ""
      )
  endif()
endif()

# BLAS in the ATLAS library? (http://math-atlas.sourceforge.net/)
if(BLA_VENDOR STREQUAL "ATLAS" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      dgemm
      ""
      "blas;f77blas;atlas"
      ""
      ""
      ""
      )
  endif()
endif()

# BLAS in PhiPACK libraries? (requires generic BLAS lib, too)
if(BLA_VENDOR STREQUAL "PhiPACK" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "sgemm;dgemm;blas"
      ""
      ""
      ""
      )
  endif()
endif()

# BLAS in Alpha CXML library?
if(BLA_VENDOR STREQUAL "CXML" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "cxml"
      ""
      ""
      ""
      )
  endif()
endif()

# BLAS in Alpha DXML library? (now called CXML, see above)
if(BLA_VENDOR STREQUAL "DXML" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "dxml"
      ""
      ""
      ""
      )
  endif()
endif()

# BLAS in Sun Performance library?
if(BLA_VENDOR STREQUAL "SunPerf" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      "-xlic_lib=sunperf"
      "sunperf;sunmath"
      ""
      ""
      ""
      )
    if(BLAS_LIBRARIES)
      set(BLAS_LINKER_FLAGS "-xlic_lib=sunperf")
    endif()
  endif()
endif()

# BLAS in SCSL library?  (SGI/Cray Scientific Library)
if(BLA_VENDOR MATCHES "SCSL" OR BLA_VENDOR STREQUAL "All")
  set(_blas_scsl_lib "scs")

  if(BLA_VENDOR MATCHES "_mp")
    set(_blas_scsl_lib "${_blas_scsl_lib}_mp")
  endif()

  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "${_blas_scsl_lib}"
      ""
      ""
      ""
      )
  endif()

  unset(_blas_scsl_lib)
endif()

# BLAS in SGIMATH library?
if(BLA_VENDOR STREQUAL "SGIMATH" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "complib.sgimath"
      ""
      ""
      ""
      )
  endif()
endif()

# BLAS in IBM ESSL library? (requires generic BLAS lib, too)
if(BLA_VENDOR STREQUAL "IBMESSL" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "essl;blas"
      ""
      ""
      ""
      )
  endif()
endif()

# BLAS in acml library?
if(BLA_VENDOR MATCHES "ACML" OR BLA_VENDOR STREQUAL "All")
  if(((BLA_VENDOR STREQUAL "ACML") AND (NOT BLAS_ACML_LIB_DIRS)) OR
    ((BLA_VENDOR STREQUAL "ACML_MP") AND (NOT BLAS_ACML_MP_LIB_DIRS)) OR
    ((BLA_VENDOR STREQUAL "ACML_GPU") AND (NOT BLAS_ACML_GPU_LIB_DIRS))
    )
  # try to find acml in "standard" paths
  if(WIN32)
    file(GLOB _ACML_ROOT "C:/AMD/acml*/ACML-EULA.txt")
  else()
    file(GLOB _ACML_ROOT "/opt/acml*/ACML-EULA.txt")
  endif()
  if(WIN32)
    file(GLOB _ACML_GPU_ROOT "C:/AMD/acml*/GPGPUexamples")
  else()
    file(GLOB _ACML_GPU_ROOT "/opt/acml*/GPGPUexamples")
  endif()
  list(GET _ACML_ROOT 0 _ACML_ROOT)
  list(GET _ACML_GPU_ROOT 0 _ACML_GPU_ROOT)
  if(_ACML_ROOT)
    get_filename_component(_ACML_ROOT ${_ACML_ROOT} PATH)
    if(SIZEOF_INTEGER EQUAL 8)
      set(_ACML_PATH_SUFFIX "_int64")
    else()
      set(_ACML_PATH_SUFFIX "")
    endif()
    if(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
      set(_ACML_COMPILER32 "ifort32")
      set(_ACML_COMPILER64 "ifort64")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
      # 32-bit not supported
      set(_ACML_COMPILER64 "ifx")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "SunPro")
      set(_ACML_COMPILER32 "sun32")
      set(_ACML_COMPILER64 "sun64")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "PGI")
      set(_ACML_COMPILER32 "pgi32")
      if(WIN32)
        set(_ACML_COMPILER64 "win64")
      else()
        set(_ACML_COMPILER64 "pgi64")
      endif()
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Open64")
      # 32 bit builds not supported on Open64 but for code simplicity
      # We'll just use the same directory twice
      set(_ACML_COMPILER32 "open64_64")
      set(_ACML_COMPILER64 "open64_64")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NAG")
      set(_ACML_COMPILER32 "nag32")
      set(_ACML_COMPILER64 "nag64")
    else()
      set(_ACML_COMPILER32 "gfortran32")
      set(_ACML_COMPILER64 "gfortran64")
    endif()

    if(BLA_VENDOR STREQUAL "ACML_MP")
      set(_ACML_MP_LIB_DIRS
        "${_ACML_ROOT}/${_ACML_COMPILER32}_mp${_ACML_PATH_SUFFIX}/lib"
        "${_ACML_ROOT}/${_ACML_COMPILER64}_mp${_ACML_PATH_SUFFIX}/lib")
    else()
      set(_ACML_LIB_DIRS
        "${_ACML_ROOT}/${_ACML_COMPILER32}${_ACML_PATH_SUFFIX}/lib"
        "${_ACML_ROOT}/${_ACML_COMPILER64}${_ACML_PATH_SUFFIX}/lib")
    endif()
  endif()
elseif(BLAS_${BLA_VENDOR}_LIB_DIRS)
  set(_${BLA_VENDOR}_LIB_DIRS ${BLAS_${BLA_VENDOR}_LIB_DIRS})
endif()

if(BLA_VENDOR STREQUAL "ACML_MP")
  foreach(BLAS_ACML_MP_LIB_DIRS ${_ACML_MP_LIB_DIRS})
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      "" "acml_mp;acml_mv" "" ${BLAS_ACML_MP_LIB_DIRS} ""
      )
    if(BLAS_LIBRARIES)
      break()
    endif()
  endforeach()
elseif(BLA_VENDOR STREQUAL "ACML_GPU")
  foreach(BLAS_ACML_GPU_LIB_DIRS ${_ACML_GPU_LIB_DIRS})
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      "" "acml;acml_mv;CALBLAS" "" ${BLAS_ACML_GPU_LIB_DIRS} ""
      )
    if(BLAS_LIBRARIES)
      break()
    endif()
  endforeach()
else()
  foreach(BLAS_ACML_LIB_DIRS ${_ACML_LIB_DIRS})
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      "" "acml;acml_mv" "" ${BLAS_ACML_LIB_DIRS} ""
      )
    if(BLAS_LIBRARIES)
      break()
    endif()
  endforeach()
endif()

# Either acml or acml_mp should be in LD_LIBRARY_PATH but not both
if(NOT BLAS_LIBRARIES)
  check_blas_libraries(
    BLAS_LIBRARIES
    BLAS
    sgemm
    ""
    "acml;acml_mv"
    ""
    ""
    ""
    )
endif()
if(NOT BLAS_LIBRARIES)
  check_blas_libraries(
    BLAS_LIBRARIES
    BLAS
    sgemm
    ""
    "acml_mp;acml_mv"
    ""
    ""
    ""
    )
endif()
if(NOT BLAS_LIBRARIES)
  check_blas_libraries(
    BLAS_LIBRARIES
    BLAS
    sgemm
    ""
    "acml;acml_mv;CALBLAS"
    ""
    ""
    ""
    )
endif()
endif() # ACML

# Apple BLAS library?
if(BLA_VENDOR STREQUAL "Apple" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      dgemm
      ""
      "Accelerate"
      ""
      ""
      ""
      )
  endif()
endif()

# Apple NAS (vecLib) library?
if(BLA_VENDOR STREQUAL "NAS" OR BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      dgemm
      ""
      "vecLib"
      ""
      ""
      ""
      )
  endif()
endif()

# Elbrus Math Library?
if(BLA_VENDOR MATCHES "EML" OR BLA_VENDOR STREQUAL "All")

   set(_blas_eml_lib "eml")

   # Check for OpenMP support, VIA BLA_VENDOR of eml_mt
   if(BLA_VENDOR MATCHES "_mt")
     set(_blas_eml_lib "${_blas_eml_lib}_mt")
   endif()

   if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "${_blas_eml_lib}"
      ""
      ""
      ""
      )
  endif()
  unset(_blas_eml_lib)
endif()

# Fujitsu SSL2 Library?
if(NOT BLAS_LIBRARIES
    AND (BLA_VENDOR MATCHES "Fujitsu_SSL2" OR BLA_VENDOR STREQUAL "All"))
  if(BLA_VENDOR STREQUAL "Fujitsu_SSL2BLAMP")
    set(_ssl2_suffix BLAMP)
  else()
    set(_ssl2_suffix)
  endif()
  check_blas_libraries(
    BLAS_LIBRARIES
    BLAS
    sgemm
    "-SSL2${_ssl2_suffix}"
    ""
    ""
    ""
    ""
    )
  if(BLAS_LIBRARIES)
    set(BLAS_LINKER_FLAGS "-SSL2${_ssl2_suffix}")
    set(_blas_fphsa_req_var BLAS_LINKER_FLAGS)
  endif()
  unset(_ssl2_suffix)
endif()

# Generic BLAS library?
if(BLA_VENDOR STREQUAL "Generic" OR
   BLA_VENDOR STREQUAL "NVHPC" OR
   BLA_VENDOR STREQUAL "All")
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "blas"
      ""
      ""
      ""
      )
  endif()
  if(NOT BLAS_LIBRARIES)
    check_blas_libraries(
      BLAS_LIBRARIES
      BLAS
      sgemm
      ""
      "blas64"
      ""
      ""
      ""
      )
  endif()
endif()

# On compilers that implicitly link BLAS (i.e. CrayPrgEnv) we used a
# placeholder for empty BLAS_LIBRARIES to get through our logic above.
if(BLAS_LIBRARIES STREQUAL "BLAS_LIBRARIES-PLACEHOLDER-FOR-EMPTY-LIBRARIES")
  set(BLAS_LIBRARIES "")
endif()

if(NOT BLA_F95)
  find_package_handle_standard_args(BLAS REQUIRED_VARS ${_blas_fphsa_req_var})
endif()

_add_blas_target()
unset(_blas_fphsa_req_var)
unset(_BLAS_LIBRARIES)