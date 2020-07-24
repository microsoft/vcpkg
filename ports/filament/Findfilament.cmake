# Distributed under the OSI-approved BSD 3-Clause License.

#.rst:
# Findfilament
# --------
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project::
#
#  ``filament_FOUND``
#    True if filament found on the local system
#
#  ``filament_INCLUDE_DIRS``
#    Location of filament header files.
#
#  ``filament_LIBRARIES``
#    The filament libraries.
#
#  ``google::filament``
#    The filament target
#

include(FindPackageHandleStandardArgs)

if(NOT filament_INCLUDE_DIR)
  find_path(filament_INCLUDE_DIR FilamentAPI.h
    PATH_SUFFIXES filament)
endif()

if(NOT filament_LIBRARY)
  find_library(filament_LIBRARY filament)
endif()

mark_as_advanced(filament_LIBRARY filament_INCLUDE_DIR)

find_package_handle_standard_args(filament
      REQUIRED_VARS  filament_INCLUDE_DIR filament_LIBRARY
)

if(WIN32)
  set(filament_DLL_DIR ${filament_INCLUDE_DIR})
  list(TRANSFORM filament_DLL_DIR APPEND "/../bin")
  find_file(filament_LIBRARY_DLL NAMES filament.dll PATHS ${filament_DLL_DIR})
endif()

set(filament_INCLUDE_DIRS ${filament_INCLUDE_DIR})
set(filament_LIBRARIES ${filament_LIBRARY})

include(CMakeFindDependencyMacro)

find_dependency(freetype CONFIG)
list(APPEND filament_LIBRARIES freetype)

if(NOT filameshio_LIBRARY)
  find_library(filameshio_LIBRARY filameshio)
endif()
list(APPEND filament_LIBRARIES ${filameshio_LIBRARY})

if(NOT filamat_lite_LIBRARY)
  find_library(filamat_lite_LIBRARY filamat_lite)
endif()
list(APPEND filament_LIBRARIES ${filamat_lite_LIBRARY})

if(NOT filaflat_LIBRARY)
  find_library(filaflat_LIBRARY filaflat)
endif()
list(APPEND filament_LIBRARIES ${filaflat_LIBRARY})

if(NOT filabridge_LIBRARY)
  find_library(filabridge_LIBRARY filabridge)
endif()
list(APPEND filament_LIBRARIES ${filabridge_LIBRARY})

if(NOT geometry_LIBRARY)
  find_library(geometry_LIBRARY geometry)
endif()
list(APPEND filament_LIBRARIES ${geometry_LIBRARY})

if(NOT backend_LIBRARY)
  find_library(backend_LIBRARY backend)
endif()
list(APPEND filament_LIBRARIES ${backend_LIBRARY})

if(NOT bluegl_LIBRARY)
  find_library(bluegl_LIBRARY bluegl)
endif()
list(APPEND filament_LIBRARIES ${bluegl_LIBRARY})

if(NOT ibl_LIBRARY)
  find_library(ibl_LIBRARY ibl)
endif()
list(APPEND filament_LIBRARIES ${ibl_LIBRARY})

if(NOT image_LIBRARY)
  find_library(image_LIBRARY image)
endif()
list(APPEND filament_LIBRARIES ${image_LIBRARY})

if(NOT meshoptimizer_LIBRARY)
  find_library(meshoptimizer_LIBRARY meshoptimizer)
endif()
list(APPEND filament_LIBRARIES ${meshoptimizer_LIBRARY})

if(NOT smolv_LIBRARY)
  find_library(smolv_LIBRARY smol-v)
endif()
list(APPEND filament_LIBRARIES ${smolv_LIBRARY})

if(NOT utils_LIBRARY)
  find_library(utils_LIBRARY utils)
endif()
list(APPEND filament_LIBRARIES ${utils_LIBRARY})

if(NOT bluevk_LIBRARY)
  find_library(bluevk_LIBRARY bluevk)
endif()
list(APPEND filament_LIBRARIES ${bluevk_LIBRARY})

if(APPLE)
    find_library(CORE_VIDEO CoreVideo)
    find_library(QUARTZ_CORE QuartzCore)
    find_library(OPENGL_LIBRARY OpenGL)
    find_library(METAL_LIBRARY Metal)
    find_library(APPKIT_LIBRARY AppKit)
    list(APPEND filament_LIBRARIES ${CORE_VIDEO} ${QUARTZ_CORE} ${OPENGL_LIBRARY} ${METAL_LIBRARY} ${APPKIT_LIBRARY})
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fobjc-link-runtime")
elseif(UNIX)
    list(APPEND filament_LIBRARIES pthread dl c++)
endif()

set(filament_LIBRARIES ${filament_LIBRARIES} CACHE STRING "TNT Filament Libraries" FORCE)

if( filament_FOUND AND NOT TARGET google::filament )
  if( EXISTS "${filament_LIBRARY_DLL}" )
    add_library( google::filament      SHARED IMPORTED )
    set_target_properties( google::filament PROPERTIES
      IMPORTED_LOCATION                 "${filament_LIBRARY_DLL}"
      IMPORTED_IMPLIB                   "${filament_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  else()
    add_library( google::filament      UNKNOWN IMPORTED )
    set_target_properties( google::filament PROPERTIES
      IMPORTED_LOCATION                 "${filament_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  endif()
endif()

if( filament_FOUND AND NOT TARGET filament )
  if( EXISTS "${filament_LIBRARY_DLL}" )
    add_library( filament      SHARED IMPORTED )
    set_target_properties( filament PROPERTIES
      IMPORTED_LOCATION                 "${filament_LIBRARY_DLL}"
      IMPORTED_IMPLIB                   "${filament_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  else()
    add_library( filament      UNKNOWN IMPORTED )
    set_target_properties( filament PROPERTIES
      IMPORTED_LOCATION                 "${filament_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  endif()
endif()
