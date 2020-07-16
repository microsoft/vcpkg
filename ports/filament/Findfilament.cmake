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
include(CMakeFindDependencyMacro)
include(SelectLibraryConfigurations)

if(NOT filament_INCLUDE_DIR)
  find_path(filament_INCLUDE_DIR FilamentAPI.h
    PATH_SUFFIXES filament)
endif()

if(NOT filament_LIBRARY)
  find_library(filament_LIBRARY_RELEASE filament)
  find_library(filament_LIBRARY_DEBUG filamentd PATHS debug debug/lib)
  select_library_configurations(filament)
endif()

mark_as_advanced(filament_LIBRARY filament_INCLUDE_DIR)

find_package_handle_standard_args(filament
    REQUIRED_VARS filament_LIBRARY filament_INCLUDE_DIR
)

if(WIN32)
  set(filament_DLL_DIR ${filament_INCLUDE_DIR})
  list(TRANSFORM filament_DLL_DIR APPEND "/../bin")
  find_file(filament_LIBRARY_DLL NAMES filament.dll PATHS ${filament_DLL_DIR})
endif()

set(filament_INCLUDE_DIRS ${filament_INCLUDE_DIR})
set(filament_LIBRARIES ${filament_LIBRARY})

if(NOT filameshio_LIBRARY)
  find_library(filameshio_LIBRARY_RELEASE filameshio)
  find_library(filameshio_LIBRARY_DEBUG filameshiod PATHS debug debug/lib)
  select_library_configurations(filameshio)
endif()
list(APPEND filament_LIBRARIES ${filameshio_LIBRARY})

if(NOT filamat_lite_LIBRARY)
  find_library(filamat_lite_LIBRARY_RELEASE filamat_lite)
  find_library(filamat_lite_LIBRARY_DEBUG filamat_lited PATHS debug debug/lib)
  select_library_configurations(filamat_lite)
endif()
list(APPEND filament_LIBRARIES ${filamat_lite_LIBRARY})

if(NOT filaflat_LIBRARY)
  find_library(filaflat_LIBRARY_RELEASE filaflat)
  find_library(filaflat_LIBRARY_DEBUG filaflatd PATHS debug debug/lib)
  select_library_configurations(filaflat)
endif()
list(APPEND filament_LIBRARIES ${filaflat_LIBRARY})

if(NOT filabridge_LIBRARY)
  find_library(filabridge_LIBRARY_RELEASE filabridge)
  find_library(filabridge_LIBRARY_DEBUG filabridged PATHS debug debug/lib)
  select_library_configurations(filabridge)
endif()
list(APPEND filament_LIBRARIES ${filabridge_LIBRARY})

if(NOT geometry_LIBRARY)
  find_library(geometry_LIBRARY_RELEASE geometry)
  find_library(geometry_LIBRARY_DEBUG geometryd PATHS debug debug/lib)
  select_library_configurations(geometry)
endif()
list(APPEND filament_LIBRARIES ${geometry_LIBRARY})

if(NOT backend_LIBRARY)
  find_library(backend_LIBRARY_RELEASE backend)
  find_library(backend_LIBRARY_DEBUG backendd PATHS debug debug/lib)
  select_library_configurations(backend)
endif()
list(APPEND filament_LIBRARIES ${backend_LIBRARY})

if(NOT bluegl_LIBRARY)
  find_library(bluegl_LIBRARY_RELEASE bluegl)
  find_library(bluegl_LIBRARY_DEBUG bluegld PATHS debug debug/lib)
  select_library_configurations(bluegl)
endif()
list(APPEND filament_LIBRARIES ${bluegl_LIBRARY})

if(NOT ibl_LIBRARY)
  find_library(ibl_LIBRARY_RELEASE ibl)
  find_library(ibl_LIBRARY_DEBUG ibld PATHS debug debug/lib)
  select_library_configurations(ibl)
endif()
list(APPEND filament_LIBRARIES ${ibl_LIBRARY})

if(NOT image_LIBRARY)
  find_library(image_LIBRARY_RELEASE image)
  find_library(image_LIBRARY_DEBUG imaged PATHS debug debug/lib)
  select_library_configurations(image)
endif()
list(APPEND filament_LIBRARIES ${image_LIBRARY})

if(NOT meshoptimizer_LIBRARY)
  find_library(meshoptimizer_LIBRARY_RELEASE meshoptimizer)
  find_library(meshoptimizer_LIBRARY_DEBUG meshoptimizerd PATHS debug debug/lib)
  select_library_configurations(meshoptimizer)
endif()
list(APPEND filament_LIBRARIES ${meshoptimizer_LIBRARY})

if(NOT smolv_LIBRARY)
  find_library(smolv_LIBRARY_RELEASE smol-v)
  find_library(smolv_LIBRARY_DEBUG smol-vd PATHS debug debug/lib)
  select_library_configurations(smolv)
endif()
list(APPEND filament_LIBRARIES ${smolv_LIBRARY})

if(NOT utils_LIBRARY)
  find_library(utils_LIBRARY_RELEASE utils)
  find_library(utils_LIBRARY_DEBUG utilsd PATHS debug debug/lib)
  select_library_configurations(utils)
endif()
list(APPEND filament_LIBRARIES ${utils_LIBRARY})

if(NOT bluevk_LIBRARY)
  find_library(bluevk_LIBRARY_RELEASE bluevk)
  find_library(bluevk_LIBRARY_DEBUG bluevkd PATHS debug debug/lib)
  select_library_configurations(bluevk)
endif()
list(APPEND filament_LIBRARIES ${bluevk_LIBRARY})

if(NOT matdbg_LIBRARY)
  find_library(matdbg_LIBRARY matdbg)
endif()
list(APPEND filament_LIBRARIES ${matdbg_LIBRARY})

if(NOT imgui_LIBRARY)
  find_library(imgui_LIBRARY_RELEASE imgui)
  find_library(imgui_LIBRARY_DEBUG imguid PATHS debug debug/lib)
  select_library_configurations(imgui)
endif()
list(APPEND filament_LIBRARIES ${imgui_LIBRARY})

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
      IMPORTED_IMPLIB_DEBUG             "${filament_LIBRARY_DEBUG}"
      IMPORTED_IMPLIB_RELEASE           "${filament_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  else()
    add_library( google::filament      UNKNOWN IMPORTED )
    set_target_properties( google::filament PROPERTIES
      IMPORTED_LOCATION_DEBUG           "${filament_LIBRARY_DEBUG}"
      IMPORTED_LOCATION_RELEASE         "${filament_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  endif()
endif()

if( filament_FOUND AND NOT TARGET filament )
  if( EXISTS "${filament_LIBRARY_DLL}" )
    add_library( filament      SHARED IMPORTED )
    set_target_properties( filament PROPERTIES
      IMPORTED_LOCATION                 "${filament_LIBRARY_DLL}"
      IMPORTED_IMPLIB_DEBUG             "${filament_LIBRARY_DEBUG}"
      IMPORTED_IMPLIB_RELEASE           "${filament_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  else()
    add_library( filament      UNKNOWN IMPORTED )
    set_target_properties( filament PROPERTIES
      IMPORTED_LOCATION_DEBUG           "${filament_LIBRARY_DEBUG}"
      IMPORTED_LOCATION_RELEASE         "${filament_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${filament_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  endif()
endif()

find_dependency(imgui CONFIG REQUIRED)
target_link_libraries(google::filament INTERFACE imgui::imgui)
target_link_libraries(filament INTERFACE imgui::imgui)
