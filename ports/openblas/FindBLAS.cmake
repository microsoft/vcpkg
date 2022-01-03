# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindBLAS
--------

Find Basic Linear Algebra Subprograms (BLAS) library

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

``OpenBLAS``

#]=======================================================================]

include(${CMAKE_ROOT}/Modules/CMakeFindDependencyMacro.cmake)

find_dependency(OpenBLAS)
set(BLAS_FOUND "${OpenBLAS_FOUND}" CACHE BOOL "" FORCE)
set(BLAS_LINKER_FLAGS "")
set(BLAS_LIBRARIES "${OpenBLAS_LIBRARIES}")
set(BLAS95_FOUND false)
set(BLAS95_LIBRARIES "")

if(TARGET OpenBLAS::OpenBLAS AND NOT TARGET BLAS::BLAS)
    add_library(BLAS::BLAS ALIAS OpenBLAS::OpenBLAS)
endif()
