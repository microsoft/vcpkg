#==========================================================================
#
#     Program: ParaView
#
#     Copyright (c) 2005-2008 Sandia Corporation, Kitware Inc.
#     All rights reserved.
#
#     ParaView is a free software; you can redistribute it and/or modify it
#     under the terms of the ParaView license version 1.2.
#
#     See License_v1.2.txt for the full ParaView license.
#     A copy of this license can be obtained by contacting
#     Kitware Inc.
#     28 Corporate Drive
#     Clifton Park, NY 12065
#     USA
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR
#  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#==========================================================================
cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(ParaView)

foreach (policy IN ITEMS
    CMP0083 # CMake 3.14
    )
  if (POLICY ${policy})
    cmake_policy(SET ${policy} NEW)
  endif ()
endforeach ()

# Disallow in-source build
if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
  message(FATAL_ERROR
    "ParaView requires an out-of-source build. Please create a separate "
    "binary directory and run CMake there.")
endif ()

#------------------------------------------------------------------------------
# Set a default build type if none was specified
get_property(generator_is_multi_config GLOBAL
  PROPERTY GENERATOR_IS_MULTI_CONFIG)
if (NOT CMAKE_BUILD_TYPE AND NOT generator_is_multi_config)
  message(STATUS "Setting build type to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE
    PROPERTY
      STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

# Set up our directory structure for output libraries and binaries
include(GNUInstallDirs)
if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")
endif ()
if (NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
endif ()
if (NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
endif ()

set(paraview_cmake_dir "${CMAKE_CURRENT_SOURCE_DIR}/CMake")
set(vtk_cmake_dir "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/vtk")
string(REPLACE "/debug" "" vtk_cmake_dir "${vtk_cmake_dir}")
message(STATUS "${vtk_cmake_dir}")
list(APPEND CMAKE_MODULE_PATH
  "${paraview_cmake_dir}"
  "${vtk_cmake_dir}")
include(ParaViewServerManager)
include(ParaViewTesting)
include(ParaViewClient)
include(ParaViewPlugin)
include(vtkModuleWrapClientServer)
include(CTest)
set_property(CACHE BUILD_TESTING
  PROPERTY
    TYPE INTERNAL)

include(vtkCompilerChecks)
include(vtkCompilerPlatformFlags)
include(vtkCompilerExtraFlags)
include(vtkInitializeBuildType)
include(vtkSupportMacros)
include(vtkDirectories)

#------------------------------------------------------------------------------
# Choose static or shared libraries.
vtk_deprecated_setting(shared_default PARAVIEW_BUILD_SHARED_LIBS BUILD_SHARED_LIBS "ON")
option(PARAVIEW_BUILD_SHARED_LIBS "Build ParaView with shared libraries" "${shared_default}")
set(BUILD_SHARED_LIBS "${PARAVIEW_BUILD_SHARED_LIBS}")
set(CMAKE_CXX_VISIBILITY_PRESET "hidden")
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

#------------------------------------------------------------------------------
# Protect against a stampede of static links at the same time.
if (NOT PARAVIEW_BUILD_SHARED_LIBS)
  set(pv_exe_job_link_pool static_exe_link)
  set_property(GLOBAL APPEND PROPERTY
    JOB_POOLS static_exe_link=1)
endif ()

#-----------------------------------------------------------------------------
# Does VTK require support for 64 bit file systems
include(CheckCXXSourceRuns)
file(READ "${vtk_cmake_dir}/vtkRequireLargeFilesSupport.cxx"
  VTK_REQUIRE_LARGE_FILE_SUPPORT_FILE)
check_cxx_source_runs("${VTK_REQUIRE_LARGE_FILE_SUPPORT_FILE}"
  CMAKE_REQUIRE_LARGE_FILE_SUPPORT "Support for 64 bit file systems")
set(VTK_REQUIRE_LARGE_FILE_SUPPORT ${CMAKE_REQUIRE_LARGE_FILE_SUPPORT})

#-----------------------------------------------------------------------------
# Provide compatibility options.
option(VTK_LEGACY_REMOVE "Remove all legacy code completely." OFF)
option(VTK_LEGACY_SILENT "Silence all legacy code messages." OFF)
mark_as_advanced(VTK_LEGACY_REMOVE VTK_LEGACY_SILENT)

# Setup external data. this will automatically download the test data and
# baseline files to the build tree and set PARAVIEW_DATA_ROOT.
include(ParaViewExternalData)

find_package(Git QUIET)
include(ParaViewDetermineVersion)

#------------------------------------------------------------------------------
# Setup ParaView Environment
#------------------------------------------------------------------------------
# Determine ParaView Source Version
# Hardcoded version variables are readin from a separate file. This makes it
# easier to have a script to update version numbers automatically.
file(STRINGS version.txt version_txt)
extract_version_components("${version_txt}" "PARAVIEW")
determine_version("${CMAKE_CURRENT_SOURCE_DIR}" "${GIT_EXECUTABLE}" "PARAVIEW")

# Setting this ensures that "make install" will leave rpaths to external
# libraries (not part of the build-tree e.g. Qt, ffmpeg, etc.) intact on
# "make install". This ensures that one can install a version of ParaView on the
# build machine without any issues. If this not desired, simply specify
# CMAKE_INSTALL_RPATH_USE_LINK_PATH when configuring Paraview and
# "make install" will strip all rpaths, which is default behavior.
if (NOT DEFINED CMAKE_INSTALL_RPATH_USE_LINK_PATH)
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif ()

include(CMakeDependentOption)
set(examples_default OFF)
if (DEFINED PARAVIEW_BUILD_EXAMPLES)
  message(DEPRECATION
    "PARAVIEW_BUILD_EXAMPLES has been renamed to PARAVIEW_ENABLE_EXAMPLES.")
  # Use the old variable as the default for the new variable if present.
  set(examples_default "${PARAVIEW_BUILD_EXAMPLES}")
  # Remove the old setting from the cache and local scope.
  unset(PARAVIEW_BUILD_EXAMPLES)
  unset(PARAVIEW_BUILD_EXAMPLES CACHE)
endif ()
option(PARAVIEW_ENABLE_EXAMPLES "Enable ParaView examples" "${examples_default}")
option(PARAVIEW_BUILD_DEVELOPER_DOCUMENTATION "Build ParaView C++/Python docs" OFF)
option(PARAVIEW_BUILD_QT_GUI "Enable ParaView Qt-based client" ON)
option(PARAVIEW_USE_MPI "Enable MPI support for parallel computing" OFF)
option(PARAVIEW_USE_VTKM "Enable VTK-m accelerated algorithms" ON)
set(raytracing_default OFF)
if (DEFINED PARAVIEW_USE_OSPRAY)
  message(DEPRECATION
    "PARAVIEW_USE_OSPRAY has been renamed to PARAVIEW_USE_RAYTRACING.")
  set(raytracing_default "${PARAVIEW_USE_OSPRAY}")
  unset(PARAVIEW_USE_OSPRAY)
  unset(PARAVIEW_USE_OSPRAY CACHE)
endif ()
option(PARAVIEW_USE_RAYTRACING "Build ParaView with OSPRay and/or OptiX ray Traced rendering" ${raytracing_default})
option(PARAVIEW_ENABLE_LOGGING "Enable logging support." ON)
mark_as_advanced(PARAVIEW_ENABLE_LOGGING)
option(PARAVIEW_INSTALL_DEVELOPMENT_FILES "Install development files to the install tree" ON)
mark_as_advanced(PARAVIEW_INSTALL_DEVELOPMENT_FILES)
option(PARAVIEW_RELOCATABLE_INSTALL "Do not embed hard-coded paths into the install" ON)
mark_as_advanced(PARAVIEW_RELOCATABLE_INSTALL)

option(PARAVIEW_ENABLE_PYTHON "Enable/Disable Python scripting support" OFF)

set(paraview_web_default ON)
if (PARAVIEW_ENABLE_PYTHON AND WIN32)
  include("${CMAKE_CURRENT_SOURCE_DIR}/VTK/CMake/FindPythonModules.cmake")
  find_python_module(win32api have_pywin32)
  set(paraview_web_default "${have_pywin32}")
endif ()
# Add ability to freeze Python modules.
cmake_dependent_option(PARAVIEW_FREEZE_PYTHON
  "Freeze Python packages/modules into the application." OFF
  # FIXME(python): Freezing is not yet supported.
  "PARAVIEW_ENABLE_PYTHON;NOT WIN32;NOT APPLE;FALSE" OFF)
mark_as_advanced(PARAVIEW_FREEZE_PYTHON)
cmake_dependent_option(PARAVIEW_ENABLE_WEB "Enable/Disable web support" "${paraview_web_default}"
  "PARAVIEW_ENABLE_PYTHON" OFF)
mark_as_advanced(PARAVIEW_ENABLE_WEB)

# NvPipe requires an NVIDIA GPU.
option(PARAVIEW_ENABLE_NVPIPE "Build ParaView with NvPipe remoting. Requires CUDA and an NVIDIA GPU" OFF)

option(PARAVIEW_ENABLE_GDAL "Enable GDAL support." OFF)
mark_as_advanced(PARAVIEW_ENABLE_GDAL)
option(PARAVIEW_ENABLE_LAS "Enable LAS support." OFF)
mark_as_advanced(PARAVIEW_ENABLE_LAS)
option(PARAVIEW_ENABLE_OPENTURNS "Enable OpenTURNS support." OFF)
option(PARAVIEW_ENABLE_PDAL "Enable PDAL support." OFF)
mark_as_advanced(PARAVIEW_ENABLE_PDAL)
option(PARAVIEW_ENABLE_MOTIONFX "Enable MotionFX support." OFF)
mark_as_advanced(PARAVIEW_ENABLE_MOTIONFX)
option(PARAVIEW_ENABLE_MOMENTINVARIANTS "Enable MomentInvariants filters" OFF)
mark_as_advanced(PARAVIEW_ENABLE_MOMENTINVARIANTS)
option(PARAVIEW_ENABLE_VISITBRIDGE "Enable VisIt readers." OFF)
option(PARAVIEW_ENABLE_XDMF2 "Enable Xdmf2 support." ON)
mark_as_advanced(PARAVIEW_ENABLE_XDMF2)
option(PARAVIEW_ENABLE_XDMF3 "Enable Xdmf3 support." OFF)

set(PARAVIEW_BUILD_TESTING "OFF"
  CACHE STRING "Build module testing directories")
set_property(CACHE PARAVIEW_BUILD_TESTING
  PROPERTY
    STRINGS "ON;OFF;WANT")
set(BUILD_TESTING OFF)
if (PARAVIEW_BUILD_TESTING)
  set(BUILD_TESTING ON)
endif ()

cmake_dependent_option(PARAVIEW_ENABLE_FFMPEG "Enable FFMPEG Support." OFF
  "UNIX" OFF)

cmake_dependent_option(PARAVIEW_USE_MPI_SSEND
  "Use MPI synchronous-send commands for communication" OFF
  "PARAVIEW_USE_MPI" OFF)
cmake_dependent_option(PARAVIEW_USE_ICE_T
  "Enable IceT (needed for parallel rendering)" ON
  "PARAVIEW_USE_MPI" OFF)
cmake_dependent_option(PARAVIEW_INITIALIZE_MPI_ON_CLIENT
  "Initialize MPI on client-processes by default. Can be overridden using command line arguments" ON
  "PARAVIEW_USE_MPI" OFF)
mark_as_advanced(
  PARAVIEW_USE_ICE_T
  PARAVIEW_USE_MPI_SSEND
  PARAVIEW_INITIALIZE_MPI_ON_CLIENT)

cmake_dependent_option(PARAVIEW_ENABLE_QT_SUPPORT
  "Build ParaView with Qt support (without GUI)" OFF
  "NOT PARAVIEW_BUILD_QT_GUI" ON)

# Add an option to enable using Qt Webkit for widgets, as needed.
# Default is OFF. We don't want to depend on WebKit unless absolutely needed.
# FIXME: Move this to the module which cares.
cmake_dependent_option(PARAVIEW_USE_QTWEBENGINE
  "Use Qt WebKit components as needed." OFF
  "PARAVIEW_ENABLE_QT_SUPPORT" OFF)
mark_as_advanced(PARAVIEW_USE_QTWEBENGINE)

# Add an option to enable using Qt Help, as needed.
# Default is ON to enable integrated help/documentation.
cmake_dependent_option(PARAVIEW_USE_QTHELP
  "Use Qt Help infrastructure as needed." ON
  "PARAVIEW_ENABLE_QT_SUPPORT" OFF)
mark_as_advanced(PARAVIEW_USE_QTHELP)

# If PARAVIEW_BUILD_QT_GUI is OFF, provide an option to the user to turn other
# command line executables ON/OFF.
cmake_dependent_option(PARAVIEW_ENABLE_COMMANDLINE_TOOLS
  "Build ParaView command-line tools" ON
  "NOT PARAVIEW_BUILD_QT_GUI" ON)

# If building on Unix with MPI enabled, we will present another option to
# enable building of CosmoTools VTK extensions. This option is by default
# OFF and set to OFF if ParaView is not built with MPI.
cmake_dependent_option(PARAVIEW_ENABLE_COSMOTOOLS
  "Build ParaView with CosmoTools VTK Extensions" OFF
  "UNIX;PARAVIEW_USE_MPI" OFF)
mark_as_advanced(PARAVIEW_ENABLE_COSMOTOOLS)

option(PARAVIEW_ENABLE_CATALYST "Enable Catalyst CoProcessing modules" ON)
cmake_dependent_option(PARAVIEW_BUILD_CATALYST_ADAPTORS
  "Build Adaptors for various simulation codes" OFF
  # XXX: Adaptors need some work yet.
  "FALSE;PARAVIEW_ENABLE_CATALYST;NOT WIN32" OFF)
mark_as_advanced(PARAVIEW_BUILD_CATALYST_ADAPTORS)

# XXX(VTK): External VTK is not yet actually supported.
if (FALSE)
option(PARAVIEW_USE_EXTERNAL_VTK "Use an external VTK." OFF)
mark_as_advanced(PARAVIEW_USE_EXTERNAL_VTK)
else ()
set(PARAVIEW_USE_EXTERNAL_VTK OFF)
endif ()

# Kits bundle multiple modules together into a single library, this
# is used to dramatically reduce the number of generated libraries.
option(PARAVIEW_ENABLE_KITS "Build ParaView using kits instead of modules." OFF)
mark_as_advanced(PARAVIEW_ENABLE_KITS)

option(PARAVIEW_USE_EXTERNAL "Use external copies of third party libraries by default" OFF)
mark_as_advanced(PARAVIEW_USE_EXTERNAL)

set(paraview_requested_modules)
set(paraview_rejected_modules)

if (PARAVIEW_ENABLE_COMMANDLINE_TOOLS AND PARAVIEW_ENABLE_PYTHON)
  list(APPEND paraview_requested_modules
    VTK::PythonInterpreter)
endif ()

if (PARAVIEW_ENABLE_PYTHON)
  set(PARAVIEW_PYTHON_VERSION "3"
    CACHE STRING "")
  set_property(CACHE PARAVIEW_PYTHON_VERSION
    PROPERTY
      STRINGS "2;3")
  if (NOT PARAVIEW_PYTHON_VERSION STREQUAL "2" AND
      NOT PARAVIEW_PYTHON_VERSION STREQUAL "3")
    message(FATAL_ERROR
      "`PARAVIEW_PYTHON_VERSION` must either be 2 or 3.")
  endif ()
  set(VTK_PYTHON_VERSION "${PARAVIEW_PYTHON_VERSION}")

  list(APPEND paraview_requested_modules
    ParaView::PythonAlgorithm
    ParaView::PythonInitializer
    ParaView::ClientServerCorePythonRendering
    VTK::RenderingMatplotlib)
else ()
  list(APPEND paraview_rejected_modules
    ParaView::PythonAlgorithm
    ParaView::PythonInitializer
    ParaView::ClientServerCorePythonRendering
    VTK::RenderingMatplotlib)
endif ()

if (PARAVIEW_ENABLE_PYTHON)
  list(APPEND paraview_requested_modules
    ParaView::CinemaPython
    ParaView::CinemaReader)
else ()
  list(APPEND paraview_rejected_modules
    ParaView::CinemaPython
    ParaView::CinemaReader)
endif()

if (PARAVIEW_ENABLE_PYTHON AND PARAVIEW_BUILD_TESTING)
  # testing needs Python interpreter i.e. `PYTHON_EXECUTABLE` without which
  # our `find_python_module` checks to determine which tests to add or exclude
  # will fail. We find it here.
  find_package(PythonInterp "${PARAVIEW_PYTHON_VERSION}" QUIET)
  mark_as_advanced(PYTHON_EXECUTABLE)
endif()

if (PARAVIEW_BUILD_QT_GUI)
  list(APPEND paraview_requested_modules
    ParaView::pqApplicationComponents
    ParaView::pqComponents
    ParaView::pqCore)
  if (PARAVIEW_ENABLE_PYTHON)
    list(APPEND paraview_requested_modules
      ParaView::pqPython)
  endif ()
else ()
  list(APPEND paraview_rejected_modules
    ParaView::pqApplicationComponents
    ParaView::pqComponents
    ParaView::pqCore
    ParaView::pqWidgets
    ParaView::qttesting
    VTK::GUISupportQt)
endif ()

if (PARAVIEW_USE_MPI)
  list(APPEND paraview_requested_modules
    VTK::FiltersParallelFlowPaths
    VTK::FiltersParallelGeometry
    VTK::FiltersParallelMPI
    # Required because of ParaView::VTKExtensionsDefault having an optional dependency.
    VTK::IOMPIImage
    VTK::IOParallelLSDyna
    VTK::IOParallelNetCDF
    VTK::ParallelMPI
    ParaView::VTKExtensionsDefaultParallel
    ParaView::icet)
  if (NOT WIN32)
    list(APPEND paraview_requested_modules
      VTK::FiltersParallelDIY2)
  endif()
else ()
  list(APPEND paraview_rejected_modules
    VTK::mpi)
endif ()

if (PARAVIEW_USE_MPI AND PARAVIEW_ENABLE_PYTHON)
  list(APPEND paraview_requested_modules
    VTK::ParallelMPI4Py)
else ()
  list(APPEND paraview_rejected_modules
    VTK::ParallelMPI4Py)
endif()

if (PARAVIEW_USE_VTKM)
  list(APPEND paraview_requested_modules
    VTK::AcceleratorsVTKm)
endif ()

if (PARAVIEW_USE_RAYTRACING)
  list(APPEND paraview_requested_modules
    VTK::RenderingRayTracing)
endif ()

if (PARAVIEW_ENABLE_NVPIPE)
  list(APPEND paraview_requested_modules
    ParaView::nvpipe)
else ()
  list(APPEND paraview_rejected_modules
    ParaView::nvpipe)
endif ()

if (PARAVIEW_ENABLE_GDAL)
  list(APPEND paraview_requested_modules
    VTK::IOGDAL)
endif ()

if (PARAVIEW_ENABLE_LAS)
  list(APPEND paraview_requested_modules
    VTK::IOLAS)
endif ()

if (PARAVIEW_ENABLE_OPENTURNS)
  list(APPEND paraview_requested_modules
    VTK::FiltersOpenTURNS)
endif ()

if (PARAVIEW_ENABLE_PDAL)
  list(APPEND paraview_requested_modules
    VTK::IOPDAL)
endif ()

if (PARAVIEW_ENABLE_MOTIONFX)
  list(APPEND paraview_requested_modules
    VTK::IOMotionFX)
endif ()

set(use_vtk_remote_modules OFF)
if (PARAVIEW_ENABLE_MOMENTINVARIANTS)
  list(APPEND paraview_requested_modules
    VTK::MomentInvariants)
  if (PARAVIEW_USE_MPI)
    list(APPEND paraview_requested_modules
      VTK::ParallelMomentInvariants)
  endif()
  set(use_vtk_remote_modules ON)
endif ()

if (PARAVIEW_ENABLE_VISITBRIDGE)
  list(APPEND paraview_requested_modules
    ParaView::IOVisItBridge
    ParaView::VisItLib)
else ()
  list(APPEND paraview_rejected_modules
    ParaView::IOVisItBridge
    ParaView::VisItLib)
endif ()

if (PARAVIEW_ENABLE_XDMF2)
  list(APPEND paraview_requested_modules
    VTK::IOXdmf2)
endif ()

if (PARAVIEW_ENABLE_XDMF3)
  list(APPEND paraview_requested_modules
    VTK::IOXdmf3)
endif ()

if (PARAVIEW_ENABLE_FFMPEG)
  list(APPEND paraview_requested_modules
    VTK::IOFFMPEG)
endif ()

if (PARAVIEW_USE_ICE_T)
  list(APPEND paraview_requested_modules
    ParaView::icet)
endif ()

if (PARAVIEW_ENABLE_COSMOTOOLS)
  list(APPEND paraview_requested_modules
    ParaView::VTKExtensionsCosmoTools)
else ()
  list(APPEND paraview_rejected_modules
    ParaView::VTKExtensionsCosmoTools)
endif ()

if (PARAVIEW_ENABLE_CATALYST)
  list(APPEND paraview_requested_modules
    ParaView::Catalyst)

  if (PARAVIEW_ENABLE_PYTHON)
    list(APPEND paraview_requested_modules
      ParaView::PythonCatalyst)
  endif ()

  if (BUILD_TESTING)
    list(APPEND paraview_requested_modules
      ParaView::CatalystTestDriver)
  endif ()

  # When Catalyst is enabled, Fortran is optionally needed. Hence we enable
  # Fortran at the top level itself. When individual module called
  # enable_language(...), it failed during first cmake configure but worked o
  # subsequent. enable_language(... OPTIONAL) overcomes that issue altogether.

  if (NOT WIN32)
    # Theoretically, CheckFortran should not be needed, but it
    # enable_language(OPTIONAL) fails with Ninja generator.
    include(CheckFortran)
    check_fortran_support()
    if (CMAKE_Fortran_COMPILER)
      enable_language(Fortran OPTIONAL)
    endif ()
  endif ()
endif ()

if (PARAVIEW_BUILD_TESTING)
  list(APPEND paraview_requested_modules
    ParaView::smTestDriver)
endif ()

list(APPEND paraview_requested_modules
  ParaView::Animation
  ParaView::ProcessXML
  ParaView::ServerManagerApplication
  ParaView::ServerManagerDefault
  ParaView::VTKExtensionsCGNSReader
  ParaView::VTKExtensionsPoints
  ParaView::WrapClientServer
  VTK::FiltersFlowPaths
  VTK::FiltersTexture
  VTK::FiltersVerdict
  VTK::IOAMR
  VTK::IOAsynchronous # needed for cinema, but no harm adding always.
  VTK::IOH5part
  VTK::IOParallelLSDyna
  VTK::IOSegY
  VTK::IOTecplotTable
  VTK::IOTRUCHAS
  VTK::IOVeraOut
  VTK::IOVPIC
  )

if (PARAVIEW_ENABLE_WEB)
  list(APPEND paraview_requested_modules
    ParaView::PVWebCore
    ParaView::PVWebPython
    ParaView::PVWebExporter
    VTK::WebCore
    VTK::WebPython
  )
  if (PARAVIEW_PYTHON_VERSION STREQUAL "2")
    list(APPEND paraview_requested_modules
      ParaView::PVWebPython2
    )
  else ()
    list(APPEND paraview_rejected_modules
      ParaView::PVWebPython2
    )
  endif ()
else()
  list(APPEND paraview_rejected_modules
    ParaView::PVWebCore
    ParaView::PVWebPython
    ParaView::PVWebPython2
    ParaView::PVWebExporter
    VTK::WebCore
    VTK::WebPython
  )
endif ()

if (paraview_requested_modules)
  list(REMOVE_DUPLICATES paraview_requested_modules)
endif ()

option(PARAVIEW_BUILD_ALL_MODULES "Build all modules by default" OFF)
mark_as_advanced(PARAVIEW_BUILD_ALL_MODULES)

if (PARAVIEW_USE_EXTERNAL_VTK)
  find_package(VTK REQUIRED)
else ()
  list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/VTK/CMake")
  include(vtkCMakeBackports)
  include(vtkModule)
  include(vtkEncodeString)
  include(vtkObjectFactory)
  include(vtkExternalData)
  include(vtkVersion)
  set(VTK_VERSION
      "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}.${VTK_BUILD_VERSION}")

  if (PARAVIEW_ENABLE_PYTHON)
    include(vtkModuleWrapPython)
  endif ()
endif ()

set_property(GLOBAL
  PROPERTY
    "_vtk_module_autoinit_include" "\"vtkAutoInit.h\"")

# Note that the way that this flag gets used, it only has an effect on the
# initial configuration.
option(PARAVIEW_PLUGINS_DEFAULT "Default state for ParaView plugins" ON)
mark_as_advanced(PARAVIEW_PLUGINS_DEFAULT)
set(paraview_default_plugins
  AcceleratedAlgorithms
  AnalyzeNIfTIReaderWriter
  ArrowGlyph
  BagPlotViewsAndFilters
  CDIReader
  DigitalRockPhysics
  EULATestPlugin
  EmbossingRepresentations
  EyeDomeLighting
  ExplicitStructuredGrid
  GenericIOReader
  GeodesicMeasurement
  GLTFReader
  GMVReader
  LagrangianParticleTracker
  Moments
  MooseXfemClip
  NetCDFTimeAnnotationPlugin
  NonOrthogonalSource
  PacMan
  PanoramicProjectionView
  # ParFlow - Because of dependency to nlohmann_json
  SLACTools
  SierraPlotTools
  StreamLinesRepresentation
  StreamingParticles
  SurfaceLIC
  ThickenLayeredCells
  VTKmFilters
  pvblot)
foreach (paraview_default_plugin IN LISTS paraview_default_plugins)
  set("_paraview_plugin_default_${paraview_default_plugin}" "${PARAVIEW_PLUGINS_DEFAULT}")
endforeach ()

set(paraview_plugin_directories
  "${CMAKE_CURRENT_SOURCE_DIR}/Plugins")
paraview_plugin_find_plugins(paraview_plugin_files ${paraview_plugin_directories})
paraview_plugin_scan(
  PLUGIN_FILES      ${paraview_plugin_files}
  PROVIDES_PLUGINS  paraview_plugins
  REQUIRES_MODULES  paraview_plugin_required_modules)

set(_vtk_module_group_default_ParaViewCore "WANT")
set(_vtk_module_group_default_ParaViewRendering "WANT")

set(paraview_source_directories
  "${CMAKE_CURRENT_SOURCE_DIR}/CoProcessing"
  "${CMAKE_CURRENT_SOURCE_DIR}/ParaViewCore"
  "${CMAKE_CURRENT_SOURCE_DIR}/Qt"
  "${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty"
  "${CMAKE_CURRENT_SOURCE_DIR}/Utilities"
  "${CMAKE_CURRENT_SOURCE_DIR}/Web")
vtk_module_find_modules(paraview_module_files ${paraview_source_directories})
vtk_module_find_kits(paraview_kit_files ${paraview_source_directories})
vtk_module_scan(
  MODULE_FILES        ${paraview_module_files}
  KIT_FILES           ${paraview_kit_files}
  REQUEST_MODULES     ${paraview_requested_modules}
                      ${paraview_plugin_required_modules}
  REJECT_MODULES      ${paraview_rejected_modules}
  PROVIDES_MODULES    paraview_modules
  PROVIDES_KITS       paraview_kits
  REQUIRES_MODULES    paraview_required_modules
  UNRECOGNIZED_MODULES paraview_unrecognized_modules
  WANT_BY_DEFAULT     "${PARAVIEW_BUILD_ALL_MODULES}"
  ENABLE_TESTS        "${PARAVIEW_BUILD_TESTING}")

set(paraview_unrecognized_paraview_modules)
foreach (paraview_module IN LISTS paraview_unrecognized_modules)
  if (paraview_module MATCHES "ParaView::")
    list(APPEND paraview_unrecognized_paraview_modules
      "${paraview_module}")
  endif ()
endforeach ()
if (paraview_unrecognized_paraview_modules)
  message(FATAL_ERROR
    "The following modules were requested or required, but not found: "
    "${paraview_unrecognized_paraview_modules}.")
endif ()

option(PARAVIEW_VERSIONED_INSTALL "Install artifacts with versioned names." ON)
mark_as_advanced(PARAVIEW_VERSIONED_INSTALL)
set(paraview_version_suffix "")
if (PARAVIEW_VERSIONED_INSTALL)
  set(paraview_version_suffix "-${PARAVIEW_VERSION_MAJOR}.${PARAVIEW_VERSION_MINOR}")
endif ()

set(paraview_cmake_destination
  "${CMAKE_INSTALL_LIBDIR}/cmake/paraview${paraview_version_suffix}")

set(PARAVIEW_CUSTOM_LIBRARY_SUFFIX "<DEFAULT>"
  CACHE STRING "Custom library file name suffix (defaults to the version number)")
mark_as_advanced(PARAVIEW_CUSTOM_LIBRARY_SUFFIX)
if (PARAVIEW_CUSTOM_LIBRARY_SUFFIX STREQUAL "<DEFAULT>")
  if (PARAVIEW_VERSIONED_INSTALL)
    set(PARAVIEW_CUSTOM_LIBRARY_SUFFIX "pv${PARAVIEW_VERSION_MAJOR}.${PARAVIEW_VERSION_MINOR}")
  else ()
    set(PARAVIEW_CUSTOM_LIBRARY_SUFFIX "")
  endif ()
endif ()

# Search for dependent libraries beside
set(_paraview_CMAKE_INSTALL_RPATH_save
  "${CMAKE_INSTALL_RPATH}")
list(APPEND CMAKE_INSTALL_RPATH
  "$ORIGIN")

if (PARAVIEW_USE_EXTERNAL_VTK)
  if (paraview_required_modules OR paraview_unrecognized_modules)
    message(FATAL_ERROR
      "The following modules were requested or required, but not found: "
      "${paraview_required_modules};${paraview_unrecognized_modules}.")
  endif ()

  if (PARAVIEW_ENABLE_PYTHON)
    find_package("Python${PARAVIEW_PYTHON_VERSION}" QUIET REQUIRED COMPONENTS Interpreter)
    set(PYTHON_VERSION_MAJOR "${Python${PARAVIEW_PYTHON_VERSION}_VERSION_MAJOR}")
    set(PYTHON_VERSION_MINOR "${Python${PARAVIEW_PYTHON_VERSION}_VERSION_MINOR}")
    if (NOT PARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX)
      vtk_module_python_default_destination(PARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX)
    endif ()
  endif ()
else ()
  set(vtk_requested_modules)
  foreach (vtk_module IN LISTS paraview_requested_modules paraview_plugin_required_modules)
    if (vtk_module MATCHES "ParaView::")
      continue ()
    endif ()
    list(APPEND vtk_requested_modules
      "${vtk_module}")
  endforeach ()
  set(vtk_rejected_modules)
  foreach (vtk_module IN LISTS paraview_rejected_modules)
    if (vtk_module MATCHES "ParaView::")
      continue ()
    endif ()
    list(APPEND vtk_rejected_modules
      "${vtk_module}")
  endforeach ()

  cmake_dependent_option(PARAVIEW_BUILD_VTK_TESTING "" OFF
    "PARAVIEW_BUILD_TESTING" OFF)
  set(vtk_enable_tests "OFF")
  if (PARAVIEW_BUILD_VTK_TESTING)
    set(vtk_enable_tests "${PARAVIEW_BUILD_TESTING}")
    # Needed for `rtImageTest.py` tests to work. See note in `vtkModuleTesting`
    # about this.
    set(VTK_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/VTK")
  endif ()

  # Forward Python option to VTK.
  set(VTK_WRAP_PYTHON "${PARAVIEW_ENABLE_PYTHON}")

  # Forward MPI option to VTK.
  set(VTK_USE_MPI "${PARAVIEW_USE_MPI}")

  # Forward logging option to VTK.
  set(VTK_ENABLE_LOGGING "${PARAVIEW_ENABLE_LOGGING}")
  if (PARAVIEW_ENABLE_LOGGING)
    list(APPEND vtk_requested_modules VTK::loguru)
  endif()

  if (use_vtk_remote_modules)
    if (PARAVIEW_ENABLE_MOMENTINVARIANTS)
      set(VTK_MODULE_ENABLE_VTK_MomentInvariants WANT)
    endif()
    # include the Remote module
    include("${CMAKE_CURRENT_SOURCE_DIR}/VTK/CMake/vtkDownload.cmake")
    # TODO: remove this after changing in vtkModuleRemote.cmake:160
    # "${VTK_SOURCE_DIR}/Remote/${_name}" to "${CMAKE_CURRENT_LIST_DIR}/${_name}"
    set(VTK_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/VTK")
    add_subdirectory(VTK/Remote)
  endif()

  vtk_module_find_modules(vtk_module_files "${CMAKE_CURRENT_SOURCE_DIR}/VTK")
  vtk_module_find_kits(vtk_kit_files "${CMAKE_CURRENT_SOURCE_DIR}/VTK")
  vtk_module_scan(
    MODULE_FILES        ${vtk_module_files}
    KIT_FILES           ${vtk_kit_files}
    REQUEST_MODULES     ${vtk_requested_modules}
                        ${paraview_required_modules}
    REJECT_MODULES      ${vtk_rejected_modules}
    PROVIDES_MODULES    vtk_modules
    PROVIDES_KITS       vtk_kits
    REQUIRES_MODULES    vtk_required_modules
    UNRECOGNIZED_MODULES vtk_unrecognized_modules
    WANT_BY_DEFAULT     OFF
    ENABLE_TESTS        "${vtk_enable_tests}"
    HIDE_MODULES_FROM_CACHE ON)

  if (vtk_required_modules OR vtk_unrecognized_modules)
    message(FATAL_ERROR
      "The following modules were requested or required, but not found: "
      "${vtk_required_modules};${vtk_unrecognized_modules}.")
  endif ()

  if (PARAVIEW_ENABLE_PYTHON)
    find_package("Python${PARAVIEW_PYTHON_VERSION}" QUIET REQUIRED COMPONENTS Interpreter)
    set(PYTHON_VERSION_MAJOR "${Python${PARAVIEW_PYTHON_VERSION}_VERSION_MAJOR}")
    set(PYTHON_VERSION_MINOR "${Python${PARAVIEW_PYTHON_VERSION}_VERSION_MINOR}")
    if (NOT PARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX)
      vtk_module_python_default_destination(PARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX)
    endif ()
    set(VTK_PYTHON_SITE_PACKAGES_SUFFIX "${PARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX}")
  endif ()

  set(VTK_BUILD_QT_DESIGNER_PLUGIN OFF)
  set(VTK_INSTALL_PYTHON_EXES OFF)

  cmake_dependent_option(VTK_NO_PYTHON_THREADS "Disable Python Threads support" ON
    "PARAVIEW_ENABLE_PYTHON" OFF)
  mark_as_advanced(VTK_NO_PYTHON_THREADS)
  cmake_dependent_option(VTK_PYTHON_FULL_THREADSAFE "Wrap all Python calls with the GIL" ON
    "NOT VTK_NO_PYTHON_THREADS" OFF)
  mark_as_advanced(VTK_PYTHON_FULL_THREADSAFE)
  cmake_dependent_option(VTK_USE_TK "Build VTK with Tk support" OFF
    "PARAVIEW_ENABLE_PYTHON" OFF)

  vtk_module_build(
    MODULES             ${vtk_modules}
    KITS                ${vtk_kits}
    PACKAGE             VTK
    INSTALL_EXPORT      VTK
    HEADERS_DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/paraview${paraview_version_suffix}"
    CMAKE_DESTINATION   "${paraview_cmake_destination}/vtk"
    HIERARCHY_DESTINATION "${CMAKE_INSTALL_LIBDIR}/vtk/hierarchy/${CMAKE_PROJECT_NAME}"
    LIBRARY_NAME_SUFFIX "${PARAVIEW_CUSTOM_LIBRARY_SUFFIX}"
    VERSION             "${PARAVIEW_VERSION}"
    SOVERSION           "1"
    TEST_DATA_TARGET    ParaViewData
    BUILD_WITH_KITS     "${PARAVIEW_ENABLE_KITS}"
    USE_EXTERNAL        "${PARAVIEW_USE_EXTERNAL}"
    TEST_INPUT_DATA_DIRECTORY   "${CMAKE_CURRENT_SOURCE_DIR}/VTK/Testing"
    TEST_OUTPUT_DATA_DIRECTORY  "${CMAKE_CURRENT_BINARY_DIR}/ExternalData/VTK/Testing")

  if (NOT PARAVIEW_USE_EXTERNAL_VTK)
    set(vtk_cmake_dir
      "${CMAKE_CURRENT_SOURCE_DIR}/VTK/CMake")
    set(vtk_cmake_destination
      "${paraview_cmake_destination}/vtk")
    set(vtk_cmake_build_dir
      "${CMAKE_CURRENT_BINARY_DIR}/${vtk_cmake_destination}")
    set(VTK_RELOCATABLE_INSTALL
      "${PARAVIEW_RELOCATABLE_INSTALL}")
    include("${CMAKE_CURRENT_SOURCE_DIR}/VTK/CMake/vtkInstallCMakePackage.cmake")
  endif ()
endif ()

set(paraview_test_data_directory_input
  "${CMAKE_CURRENT_SOURCE_DIR}/Testing")
set(paraview_test_data_directory_output
  "${CMAKE_CURRENT_BINARY_DIR}/ExternalData")
set(_paraview_add_tests_default_data_directory
  "${paraview_test_data_directory_output}")
set(_paraview_add_tests_default_test_data_target
  "ParaViewData")

vtk_module_build(
  MODULES             ${paraview_modules}
  KITS                ${paraview_kits}
  INSTALL_EXPORT      ParaView
  HEADERS_DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/paraview${paraview_version_suffix}"
  CMAKE_DESTINATION   "${paraview_cmake_destination}"
  HIERARCHY_DESTINATION "${CMAKE_INSTALL_LIBDIR}/vtk/hierarchy/${CMAKE_PROJECT_NAME}"
  LIBRARY_NAME_SUFFIX "${PARAVIEW_CUSTOM_LIBRARY_SUFFIX}"
  VERSION             "${PARAVIEW_VERSION}"
  SOVERSION           "1"
  TEST_DATA_TARGET    ParaViewData
  BUILD_WITH_KITS     "${PARAVIEW_ENABLE_KITS}"
  USE_EXTERNAL        "${PARAVIEW_USE_EXTERNAL}"
  TEST_INPUT_DATA_DIRECTORY   "${paraview_test_data_directory_input}"
  TEST_OUTPUT_DATA_DIRECTORY  "${paraview_test_data_directory_output}")

include(vtkModuleJson)
vtk_module_json(
  MODULES "${vtk_modules}"
  OUTPUT "vtk-modules.json")
vtk_module_json(
  MODULES "${paraview_modules}"
  OUTPUT "paraview-modules.json")

paraview_plugin_build(
  RUNTIME_DESTINATION   "${CMAKE_INSTALL_BINDIR}"
  LIBRARY_DESTINATION   "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY_SUBDIRECTORY  "paraview${paraview_version_suffix}/plugins"
  PLUGINS_FILE_NAME ".plugins"
  TARGET  paraview_plugins
  PLUGINS ${paraview_plugins})

set(CMAKE_INSTALL_RPATH
  "${_paraview_CMAKE_INSTALL_RPATH_save}")

vtk_module_wrap_client_server(
  MODULES   ${paraview_modules}
            ${vtk_modules}
  TARGET    paraview_client_server
  INSTALL_EXPORT ParaView)

paraview_server_manager_process(
  MODULES   ${paraview_modules}
            ${vtk_modules}
  TARGET    paraview_server_manager
  XML_FILES paraview_server_manager_files
  INSTALL_EXPORT ParaView)

if (PARAVIEW_ENABLE_PYTHON)
  if (PARAVIEW_USE_EXTERNAL_VTK)
    # TODO: Check if VTK is already wrapped in Python.
    # Error out?
  else ()
    vtk_module_wrap_python(
      MODULES         ${vtk_modules}
      INSTALL_EXPORT  VTKPython
      PYTHON_PACKAGE  "vtkmodules"
      MODULE_DESTINATION  "${PARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX}"
      CMAKE_DESTINATION   "${paraview_cmake_destination}/vtk"
      LIBRARY_DESTINATION "${CMAKE_INSTALL_LIBDIR}"
      WRAPPED_MODULES vtk_python_wrapped_modules
      TARGET          VTK::vtkpythonmodules)

    add_subdirectory(VTK/Wrapping/Python)

    export(
      EXPORT    VTKPython
      NAMESPACE VTK::
      FILE      "${CMAKE_BINARY_DIR}/${paraview_cmake_destination}/vtk/VTKPython-targets.cmake")
    install(
      EXPORT      VTKPython
      NAMESPACE   VTK::
      FILE        VTKPython-targets.cmake
      DESTINATION "${paraview_cmake_destination}/vtk"
      COMPONENT   "development")
  endif ()

  get_property(vtk_required_python_modules GLOBAL
    PROPERTY  vtk_required_python_modules)
  if (vtk_required_python_modules)
    list(REMOVE_DUPLICATES vtk_required_python_modules)
  endif ()
  string(REPLACE ";" "\n" vtk_required_python_modules "${vtk_required_python_modules}")
  file(WRITE "${CMAKE_BINARY_DIR}/requirements.txt"
    "${vtk_required_python_modules}\n")

  vtk_module_wrap_python(
    MODULES         ${paraview_modules}
    INSTALL_EXPORT  ParaViewPython
    PYTHON_PACKAGE  "paraview.modules"
    MODULE_DESTINATION  "${PARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX}"
    CMAKE_DESTINATION   "${paraview_cmake_destination}"
    LIBRARY_DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    WRAPPED_MODULES paraview_python_wrapped_modules
    TARGET          ParaView::pvpythonmodules)

  export(
    EXPORT    ParaViewPython
    NAMESPACE ParaView::
    FILE      "${CMAKE_BINARY_DIR}/${paraview_cmake_destination}/ParaViewPython-targets.cmake")
  install(
    EXPORT      ParaViewPython
    NAMESPACE   ParaView::
    FILE        ParaViewPython-targets.cmake
    DESTINATION "${paraview_cmake_destination}"
    COMPONENT   "development")
endif ()

if (PARAVIEW_ENABLE_WEB)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/Web/package.json.in"
    "${CMAKE_CURRENT_BINARY_DIR}/package.json"
    @ONLY)
endif ()

if (PARAVIEW_ENABLE_COMMANDLINE_TOOLS)
  add_subdirectory(CommandLineExecutables)
endif ()
add_subdirectory(Applications)

if (PARAVIEW_ENABLE_PYTHON)
  add_subdirectory(Wrapping/Python)
endif ()

if (NOT PARAVIEW_USE_EXTERNAL_VTK)
  # Configure the CTestCustom.cmake file for exclusions.
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/VTK/CMake/CTestCustom.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/VTK/CTestCustom.cmake"
    @ONLY)
endif ()

# Configure the CTestCustom.cmake file for exclusions.
configure_file(
  "${paraview_cmake_dir}/CTestCustom.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake"
  @ONLY)

ExternalData_Add_Target(ParaViewData)

set(paraview_cmake_build_dir
  "${CMAKE_CURRENT_BINARY_DIR}/${paraview_cmake_destination}")
include("${CMAKE_CURRENT_SOURCE_DIR}/CMake/ParaViewInstallCMakePackage.cmake")

set(is_git FALSE)
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git")
  set(is_git TRUE)
endif ()

if (NOT WIN32 AND is_git AND Git_FOUND AND NOT GIT_VERSION_STRING VERSION_LESS "2.18.0")
  set(source_all)
  if (PARAVIEW_SOURCE_TARBALL_TARGETS)
    set(source_all ALL)
  endif ()

  add_custom_target(paraview-source ${source_all})
  foreach (format tgz txz zip)
    add_custom_target("paraview-source-${format}" ${source_all}
      COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/Utilities/Maintenance/create_tarballs.bash"
              "--${format}"
      WORKING_DIRECTORY
              "${CMAKE_CURRENT_BINARY_DIR}"
      COMMENT "Creating source tarball in ${format} format")
    add_dependencies("paraview-source-${format}"
      ParaViewData)
    add_dependencies(paraview-source
      "paraview-source-${format}")
  endforeach ()
  # This is a hack.  Git version 2.17 does NOT like running these in parallel and
  # reports that a lockfile is already locked.  In order for the build to succeed,
  # force these to run in serial.
  add_dependencies(paraview-source-tgz paraview-source-txz)
  add_dependencies(paraview-source-txz paraview-source-zip)
endif ()

# This is the directory under which all generated docs, such as Doxygen and
# Sphinx generated docs, are placed.
if (NOT PARAVIEW_GENERATED_DOCUMENTATION_OUTPUT_DIRECTORY)
  set(PARAVIEW_GENERATED_DOCUMENTATION_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/doc")
endif ()

#-----------------------------------------------------------------------------
# Build doxygen documentation.
if (PARAVIEW_BUILD_DEVELOPER_DOCUMENTATION)
  add_subdirectory(Utilities/Doxygen)
  add_subdirectory(Utilities/Sphinx)
  add_subdirectory(Documentation)
endif()

#------------------------------------------------------------------------------
# Test to check install tree
#------------------------------------------------------------------------------
if (BUILD_TESTING AND PARAVIEW_INSTALL_DEVELOPMENT_FILES)
  add_test( NAME pv.TestDevelopmentInstall
    COMMAND ${CMAKE_COMMAND}
    -DPARAVIEW_BINARY_DIR:PATH=${CMAKE_BINARY_DIR}
    -DPARAVIEW_INSTALL_DIR:PATH=${CMAKE_INSTALL_PREFIX}
    -DPARAVIEW_SOURCE_DIR:PATH=${CMAKE_SOURCE_DIR}
    -DPARAVIEW_TEST_DIR:PATH=${CMAKE_BINARY_DIR}/Testing/Temporary
    -DPARAVIEW_CMAKE_DESTINATION:STRING=${paraview_cmake_destination}
    -DCMAKE_GENERATOR:STRING=${CMAKE_GENERATOR}
    -DCMAKE_GENERATOR_PLATFORM:STRING=${CMAKE_GENERATOR_PLATFORM}
    -DCMAKE_GENERATOR_TOOLSET:STRING=${CMAKE_GENERATOR_TOOLSET}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/CMake/ParaViewTestInstall.cmake)
  set_tests_properties(pv.TestDevelopmentInstall PROPERTIES
    LABELS "paraview"
    ENVIRONMENT "DESTDIR=${CMAKE_BINARY_DIR}/test-install")
endif()
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Test to check that we can process all of the Catalyst editions
#------------------------------------------------------------------------------
if (BUILD_TESTING AND PARAVIEW_ENABLE_PYTHON AND UNIX AND NOT APPLE)
if (FALSE) # XXX(FIXME)
  # disabling till we Catalyst editions are fixed post modularization
  add_test( NAME GenerateCatalystEditions
    COMMAND ${CMAKE_COMMAND}
    -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
    -DPARAVIEW_SOURCE_DIR:PATH=${CMAKE_SOURCE_DIR}
    -DPARAVIEW_TEST_DIR:PATH=${CMAKE_BINARY_DIR}/Testing/Temporary
    -P ${CMAKE_SOURCE_DIR}/CMake/ParaViewTestCatalystCodeGeneration.cmake)
  set_tests_properties(GenerateCatalystEditions PROPERTIES
    LABELS "paraview;catalyst")
endif()
endif()
#------------------------------------------------------------------------------

#-----------------------------------------------------------------------------
if (PARAVIEW_BUILD_CATALYST_ADAPTORS)
  # BuildAdaptors.cmake builds the adaptors as a separate project. We mark is
  # OPTIONAL for Catalyst packages that don't have the adaptors included.
  include(${CMAKE_CURRENT_SOURCE_DIR}/CoProcessing/Adaptors/BuildAdaptors.cmake
          OPTIONAL)
endif()

#-----------------------------------------------------------------------------
if (PARAVIEW_ENABLE_EXAMPLES)
  add_subdirectory(Examples)
endif ()
