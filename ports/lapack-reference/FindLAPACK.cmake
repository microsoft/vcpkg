# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindLAPACK
----------

Find Linear Algebra PACKage (LAPACK) library

This module finds an installed Fortran library that implements the
`LAPACK linear-algebra interface`_.

At least one of the ``C``, ``CXX``, or ``Fortran`` languages must be enabled.

.. _`LAPACK linear-algebra interface`: http://www.netlib.org/lapack/

Input Variables
^^^^^^^^^^^^^^^

The following variables may be set to influence this module's behavior:

``BLA_STATIC``
  if ``ON`` use static linkage

``BLA_VENDOR``
  Set to one of the :ref:`BLAS/LAPACK Vendors` to search for BLAS only
  from the specified vendor.  If not set, all vendors are considered.

``BLA_F95``
  if ``ON`` tries to find the BLAS95/LAPACK95 interfaces

``BLA_PREFER_PKGCONFIG``
  .. versionadded:: 3.20

  if set ``pkg-config`` will be used to search for a LAPACK library first
  and if one is found that is preferred

Imported targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

``LAPACK::LAPACK``
  .. versionadded:: 3.18

  The libraries to use for LAPACK, if found.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

``LAPACK_FOUND``
  library implementing the LAPACK interface is found
``LAPACK_LINKER_FLAGS``
  uncached list of required linker flags (excluding ``-l`` and ``-L``).
``LAPACK_LIBRARIES``
  uncached list of libraries (using full path name) to link against
  to use LAPACK
``LAPACK95_LIBRARIES``
  uncached list of libraries (using full path name) to link against
  to use LAPACK95
``LAPACK95_FOUND``
  library implementing the LAPACK95 interface is found

Intel MKL
^^^^^^^^^

To use the Intel MKL implementation of LAPACK, a project must enable at least
one of the ``C`` or ``CXX`` languages.  Set ``BLA_VENDOR`` to an Intel MKL
variant either on the command-line as ``-DBLA_VENDOR=Intel10_64lp`` or in
project code:

.. code-block:: cmake

  set(BLA_VENDOR Intel10_64lp)
  find_package(LAPACK)

In order to build a project using Intel MKL, and end user must first
establish an Intel MKL environment.  See the :module:`FindBLAS` module
section on :ref:`Intel MKL` for details.

#]=======================================================================]

# The approach follows that of the ``autoconf`` macro file, ``acx_lapack.m4``
# (distributed at http://ac-archive.sourceforge.net/ac-archive/acx_lapack.html).

if(CMAKE_Fortran_COMPILER_LOADED)
  include("${CMAKE_ROOT}/Modules/CheckFortranFunctionExists.cmake")
else()
  include("${CMAKE_ROOT}/Modules/CheckFunctionExists.cmake")
endif()
include("${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake")

function(_add_lapack_target)
  if(LAPACK_FOUND AND NOT TARGET LAPACK::LAPACK)
    add_library(LAPACK::LAPACK INTERFACE IMPORTED)

    # Filter out redundant BLAS info and replace with the BLAS target
    set(_lapack_libs "${LAPACK_LIBRARIES}")
    set(_lapack_flags "${LAPACK_LINKER_FLAGS}")
    if(TARGET BLAS::BLAS)
      if(_lapack_libs AND BLAS_LIBRARIES)
        foreach(_blas_lib IN LISTS BLAS_LIBRARIES)
          list(REMOVE_ITEM _lapack_libs "${_blas_lib}")
        endforeach()
      endif()
      if(_lapack_flags AND BLAS_LINKER_FLAGS)
        foreach(_blas_flag IN LISTS BLAS_LINKER_FLAGS)
          list(REMOVE_ITEM _lapack_flags "${_blas_flag}")
        endforeach()
      endif()
      list(APPEND _lapack_libs BLAS::BLAS)
    endif()
    if(_lapack_libs)
      set_target_properties(LAPACK::LAPACK PROPERTIES
        INTERFACE_LINK_LIBRARIES "${_lapack_libs}"
      )
    endif()
    if(_lapack_flags)
      set_target_properties(LAPACK::LAPACK PROPERTIES
        INTERFACE_LINK_OPTIONS "${_lapack_flags}"
      )
    endif()
  endif()
endfunction()

# TODO: move this stuff to a separate module

function(CHECK_LAPACK_LIBRARIES LIBRARIES _prefix _name _flags _list _deps _addlibdir _subdirs _blas)
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
    set(CMAKE_REQUIRED_LIBRARIES ${_flags} ${_libraries} ${_blas} ${_deps})
    set(CMAKE_REQUIRED_QUIET ${LAPACK_FIND_QUIETLY})
    if(CMAKE_Fortran_COMPILER_LOADED)
      check_fortran_function_exists("${_name}" ${_prefix}${_combined_name}_WORKS)
    else()
      check_function_exists("${_name}_" ${_prefix}${_combined_name}_WORKS)
    endif()
    set(CMAKE_REQUIRED_LIBRARIES)
    set(_libraries_work ${${_prefix}${_combined_name}_WORKS})
  endif()

  if(_libraries_work)
    if("${_list}${_blas}" STREQUAL "")
      set(_libraries "${LIBRARIES}-PLACEHOLDER-FOR-EMPTY-LIBRARIES")
    else()
      list(APPEND _libraries ${_blas} ${_deps})
    endif()
  else()
    set(_libraries FALSE)
  endif()
  set(${LIBRARIES} "${_libraries}" PARENT_SCOPE)
endfunction()

macro(_lapack_find_dependency dep)
  set(_lapack_quiet_arg)
  if(LAPACK_FIND_QUIETLY)
    set(_lapack_quiet_arg QUIET)
  endif()
  set(_lapack_required_arg)
  if(LAPACK_FIND_REQUIRED)
    set(_lapack_required_arg REQUIRED)
  endif()
  find_package(${dep} ${ARGN}
    ${_lapack_quiet_arg}
    ${_lapack_required_arg}
  )
  if (NOT ${dep}_FOUND)
    set(LAPACK_NOT_FOUND_MESSAGE "LAPACK could not be found because dependency ${dep} could not be found.")
  endif()

  set(_lapack_required_arg)
  set(_lapack_quiet_arg)
endmacro()

set(LAPACK_LINKER_FLAGS)
set(LAPACK_LIBRARIES)
set(LAPACK95_LIBRARIES)
set(_lapack_fphsa_req_var LAPACK_LIBRARIES)

# Check the language being used
if(NOT (CMAKE_C_COMPILER_LOADED OR CMAKE_CXX_COMPILER_LOADED OR CMAKE_Fortran_COMPILER_LOADED))
  set(LAPACK_NOT_FOUND_MESSAGE
    "FindLAPACK requires Fortran, C, or C++ to be enabled.")
endif()

# Load BLAS
if(NOT LAPACK_NOT_FOUND_MESSAGE)
  _lapack_find_dependency(BLAS)
endif()

# Search with pkg-config if specified
if(BLA_PREFER_PKGCONFIG)
  find_package(PkgConfig)
  pkg_check_modules(PKGC_LAPACK lapack)
  if(PKGC_LAPACK_FOUND)
    set(LAPACK_FOUND TRUE)
    set(LAPACK_LIBRARIES "${PKGC_LAPACK_LINK_LIBRARIES}")
    if (BLAS_LIBRARIES)
      list(APPEND LAPACK_LIBRARIES "${BLAS_LIBRARIES}")
    endif()
    _add_lapack_target()
    return()
  endif()
endif()

# Search for different LAPACK distributions if BLAS is found
if(NOT LAPACK_NOT_FOUND_MESSAGE)
  set(LAPACK_LINKER_FLAGS ${BLAS_LINKER_FLAGS})
  if(NOT $ENV{BLA_VENDOR} STREQUAL "")
    set(BLA_VENDOR $ENV{BLA_VENDOR})
  elseif(NOT BLA_VENDOR)
    set(BLA_VENDOR "All")
  endif()

  # Generic LAPACK library?
  if(NOT LAPACK_LIBRARIES
      AND (BLA_VENDOR STREQUAL "Generic"
           OR BLA_VENDOR STREQUAL "ATLAS"
           OR BLA_VENDOR STREQUAL "All"))
    if(BLA_STATIC)
      # We do not know for sure how the LAPACK reference implementation
      # is built on this host.  Guess typical dependencies.
      set(_lapack_generic_deps "-lgfortran;-lm")
    else()
      set(_lapack_generic_deps "")
    endif()
    check_lapack_libraries(
      LAPACK_LIBRARIES
      LAPACK
      cheev
      ""
      "lapack"
      "${_lapack_generic_deps}"
      ""
      ""
      "${BLAS_LIBRARIES}"
    )
    unset(_lapack_generic_deps)
  endif()
endif()

if(BLA_F95)
  set(LAPACK_LIBRARIES "${LAPACK95_LIBRARIES}")
endif()

if(LAPACK_NOT_FOUND_MESSAGE)
  set(LAPACK_NOT_FOUND_MESSAGE
    REASON_FAILURE_MESSAGE ${LAPACK_NOT_FOUND_MESSAGE})
endif()
find_package_handle_standard_args(LAPACK REQUIRED_VARS ${_lapack_fphsa_req_var}
  ${LAPACK_NOT_FOUND_MESSAGE})
unset(LAPACK_NOT_FOUND_MESSAGE)

if(BLA_F95)
  set(LAPACK95_FOUND ${LAPACK_FOUND})
endif()

# On compilers that implicitly link LAPACK (such as ftn, cc, and CC on Cray HPC machines)
# we used a placeholder for empty LAPACK_LIBRARIES to get through our logic above.
if(LAPACK_LIBRARIES STREQUAL "LAPACK_LIBRARIES-PLACEHOLDER-FOR-EMPTY-LIBRARIES")
  set(LAPACK_LIBRARIES "")
endif()

_add_lapack_target()
