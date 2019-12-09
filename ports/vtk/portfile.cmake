if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "You will need to install Xorg dependencies to build vtk:\napt-get install libxt-dev\n")
endif()

# TODO:
# - add loguru as a dependency requires #8682

# =============================================================================
# Options:
# Collect CMake options for optional components
if("qt" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_GROUP_ENABLE_Qt=YES
        -DVTK_BUILD_QT_DESIGNER_PLUGIN=OFF
        -DVTK_MODULE_ENABLE_VTK_RenderingQt=YES
        -DVTK_MODULE_ENABLE_VTK_ViewsQt=YES
    )
endif()

if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_WRAP_PYTHON=ON
        -DVTK_PYTHON_VERSION=3
    )
endif()

if("paraview" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_FiltersParallelStatistics=YES
        -DVTK_MODULE_ENABLE_VTK_IOParallelExodus=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingParallel=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingVolumeAMR=YES
        -DVTK_MODULE_ENABLE_VTK_IOXdmf2=YES
        -DVTK_MODULE_ENABLE_VTK_IOH5part=YES
        -DVTK_MODULE_ENABLE_VTK_IOParallelLSDyna=YES
        -DVTK_MODULE_ENABLE_VTK_IOTRUCHAS=YES
        -DVTK_MODULE_ENABLE_VTK_IOVPIC=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingLICOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingAnnotation=YES
        #-DVTK_MODULE_ENABLE_VTK_mpi=YES
        #-DVTK_MODULE_ENABLE_VTK_ParallelMPI=YES
        #-DVTK_MODULE_ENABLE_VTK_ParallelMPI4Py=YES
        #-DVTK_MODULE_ENABLE_VTK_WebCore=YES
        #-DVTK_MODULE_ENABLE_VTK_WebPython=YES
    )
endif()

if("mpi" IN_LIST FEATURES)
    set(VTK_GROUP_ENABLE_MPI                 NO)
endif()

if("all" IN_LIST FEATURES)
    set(VTK_WITH_ALL_MODULES                 ON) # IMPORTANT: if ON make sure `qt5`, `mpi`, `python3`, `ffmpeg`, `gdal`, `fontconfig`,
                                                  #            `libmysql` and `atlmfc` are  listed as dependency in the CONTROL file
else()
    set(VTK_WITH_ALL_MODULES                 OFF)
endif()

# =============================================================================
# Clone & patch
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/VTK
    REF e4e8a4df9cc67fd2bb3dbb3b1c50a25177cbfe68 # VTK commit used by ParaView v5.7.0
    SHA512 058607a2000535474eb09ac4318937035733105b28a2fa1fef0857dc94d586239460d5d67d0c0c733984df4dc3bcb91720b2a0c16e7edf7c691b378c8ced6cc9
    HEAD_REF master
    PATCHES
        MR6108.patch # Fixes usage of system pugixml! (Already merged in master)
        FindHDF5.patch # completly replaces FindHDF5
        FindLibHaru.patch
        FindLZMA.patch
        findproj.patch
        vtkm.patch # To include an external VTKm build (v.1.3 required)
        #install_private_headers.patch #Required by ParaView, also vtkStatisticsAlgorithmPrivate vtkCompositePolyDataMapper2Internal vtkTextureObjectVS(from build)
)

# Remove the FindGLEW.cmake and FindPythonLibs.cmake that are distributed with VTK,
# since they do not detect the debug libraries correctly.
# The default files distributed with CMake (>= 3.9) should be superior by all means.
# For GDAL, the one distributed with CMake does not detect the debug libraries correctly,
# so we provide an own one.
#file(REMOVE ${SOURCE_PATH}/CMake/FindGLEW.cmake)
#file(REMOVE ${SOURCE_PATH}/CMake/FindPythonLibs.cmake)

#file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindGDAL.cmake DESTINATION ${SOURCE_PATH}/CMake)

# =============================================================================


if(VTK_WITH_ALL_MODULES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_BUILD_ALL_MODULES=ON
        -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
    )
endif()

find_library(PYTHON_LIBRARY_RELEASE python37 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(PYTHON_LIBRARY_DEBUG python37_d python37 PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
if(PYTHON_LIBRARY_RELEASE)
    list(APPEND PYTHON_LIBRARY "optimized\\\\\;${PYTHON_LIBRARY_RELEASE}")
endif()
if(PYTHON_LIBRARY_DEBUG)
    list(APPEND PYTHON_LIBRARY "debug\\\\\;${PYTHON_LIBRARY_DEBUG}")
endif()
# =============================================================================
# Configure & Install

# We set all libraries to "system" and explicitly list the ones that should use embedded copies

# set(EXTERNAL_MODULES doubleconversion eigen expat freetype glew hdf5 jpeg jsoncpp libharu libproj libxml2 lz4 lzma netcdf ogg pugixml sqlite theora tiff utf8 zlib)
# foreach(dep IN_LIST EXTERNAL_MODULES)
    # list(APPEND ADDITIONAL_OPTIONS -DVTK_MODULE_USE_EXTERNAL_VTK_${dep}:BOOL=ON)
# endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DVTK_BUILD_TESTING=OFF
        -DVTK_BUILD_EXAMPLES=OFF
        -DVTK_INSTALL_INCLUDE_DIR=include
        -DVTK_INSTALL_DATA_DIR=share/vtk/data
        -DVTK_INSTALL_DOC_DIR=share/vtk/doc
        -DVTK_INSTALL_PACKAGE_DIR=share/vtk
        -DVTK_INSTALL_RUNTIME_DIR=bin
        -DVTK_FORBID_DOWNLOADS=ON
        #VTK groups to enable
        -DVTK_GROUP_ENABLE_StandAlone=YES
        -DVTK_GROUP_ENABLE_Rendering=YES
        -DVTK_GROUP_ENABLE_Views=YES
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKm=YES
        -DVTK_MODULE_ENABLE_VTK_vtkm=YES
        # Select modules / groups to install
        -DVTK_USE_EXTERNAL:BOOL=ON
        -DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps:BOOL=OFF
        #-DPYTHON_EXECUTABLE=${PYTHON3}
        #-DPython3_LIBRARIES="${PYTHON_LIBRARY}"

        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# =============================================================================
# Fixup target files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/vtk-8.90)

# For some reason the references to the XDMF libraries in the target files do not end up
# correctly, so we fix them here.
# if(VTK_WITH_ALL_MODULES)
    # file(READ ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake VTK_TARGETS_RELEASE_CONTENT)
    # string(REPLACE "lib/../XdmfCore.lib" "lib/XdmfCore.lib" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    # string(REPLACE "bin/../XdmfCore.dll" "bin/XdmfCore.dll" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    # string(REPLACE "lib/../vtkxdmf3.lib" "lib/vtkxdmf3.lib" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    # string(REPLACE "bin/../vtkxdmf3.dll" "bin/vtkxdmf3.dll" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    # file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake "${VTK_TARGETS_RELEASE_CONTENT}")

    # file(READ ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake VTK_TARGETS_DEBUG_CONTENT)
    # string(REPLACE "lib/../XdmfCore.lib" "lib/XdmfCore.lib" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    # string(REPLACE "bin/../XdmfCore.dll" "bin/XdmfCore.dll" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    # string(REPLACE "lib/../vtkxdmf3.lib" "lib/vtkxdmf3.lib" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    # string(REPLACE "bin/../vtkxdmf3.dll" "bin/vtkxdmf3.dll" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    # file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake "${VTK_TARGETS_DEBUG_CONTENT}")
# endif()

# =============================================================================
# Clean-up other directories

# Delete the debug binary TOOL_NAME that is not required
function(_vtk_remove_debug_tool TOOL_NAME)
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE ${filename})
    endif()
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}d${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE ${filename})
    endif()
    # we also have to bend the lines referencing the tools in VTKTargets-debug.cmake
    # to make them point to the release version of the tools
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-debug.cmake" VTK_TARGETS_CONTENT_DEBUG)
    string(REPLACE "debug/bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
    string(REPLACE "tools/vtk/${TOOL_NAME}d" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-debug.cmake" "${VTK_TARGETS_CONTENT_DEBUG}")
endfunction()

# Move the release binary TOOL_NAME from bin to tools
function(_vtk_move_release_tool TOOL_NAME)
    set(old_filename "${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(EXISTS ${old_filename})
        file(INSTALL ${old_filename} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/vtk")
        file(REMOVE ${old_filename})
    endif()

    # we also have to bend the lines referencing the tools in VTKTargets-release.cmake
    # to make them point to the tool folder
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-release.cmake" VTK_TARGETS_CONTENT_RELEASE)
    string(REPLACE "bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_RELEASE "${VTK_TARGETS_CONTENT_RELEASE}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-release.cmake" "${VTK_TARGETS_CONTENT_RELEASE}")
    
    if("python" IN_LIST FEATURES)
    endif()
endfunction()

set(VTK_SHORT_VERSION 8.90)
set(VTK_TOOLS
    vtkEncodeString-${VTK_SHORT_VERSION}
    vtkHashSource-${VTK_SHORT_VERSION}
    vtkWrapTclInit-${VTK_SHORT_VERSION}
    vtkWrapTcl-${VTK_SHORT_VERSION}
    vtkWrapPythonInit-${VTK_SHORT_VERSION}
    vtkWrapPython-${VTK_SHORT_VERSION}
    vtkWrapJava-${VTK_SHORT_VERSION}
    vtkWrapHierarchy-${VTK_SHORT_VERSION}
    vtkParseJava-${VTK_SHORT_VERSION}
    vtkParseOGLExt-${VTK_SHORT_VERSION}
    vtkProbeOpenGLVersion-${VTK_SHORT_VERSION}
    vtkTestOpenGLVersion-${VTK_SHORT_VERSION}
    vtkpython
    pvtkpython
)

foreach(TOOL_NAME IN LISTS VTK_TOOLS)
    _vtk_remove_debug_tool("${TOOL_NAME}")
    _vtk_move_release_tool("${TOOL_NAME}")
endforeach()

# =============================================================================
# Remove other files and directories that are not valid for vcpkg
# if(VTK_WITH_ALL_MODULES)
    # file(REMOVE ${CURRENT_PACKAGES_DIR}/XdmfConfig.cmake)
    # file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/XdmfConfig.cmake)
# endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# =============================================================================
# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk/copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/vtk)

## Files Modules needed by ParaView
if("paraview" IN_LIST FEATURES)
    set(VTK_CMAKE_NEEDED vtkCompilerChecks vtkCompilerPlatformFlags vtkCompilerExtraFlags vtkInitializeBuildType vtkSupportMacros vtkDirectories vtkVersion FindPythonModules)
    foreach(module ${VTK_CMAKE_NEEDED})
        file(INSTALL "${SOURCE_PATH}/CMake/${module}.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
    endforeach()
    file(INSTALL "${SOURCE_PATH}/CMake/vtkRequireLargeFilesSupport.cxx" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
    
    #ParaView requires some internal headers
    file(INSTALL ${SOURCE_PATH}/Rendering/Annotation/vtkScalarBarActorInternal.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-8.90)
    file(INSTALL ${SOURCE_PATH}/Filters/Statistics/vtkStatisticsAlgorithmPrivate.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-8.90)
    file(INSTALL ${SOURCE_PATH}/Filters/Statistics/vtkCompositePolyDataMapper2Internal.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-8.90)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Rendering/OpenGL2/vtkTextureObjectVS.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-8.90)
endif()

#TODO remove one get_filename_component(_vtk_module_import_prefix "${_vtk_module_import_prefix}" DIRECTORY) from vtk-prefix.cmake and VTK-vtk-module-properties and vtk-python.cmake
set(filenames_fix_prefix vtk-prefix VTK-vtk-module-properties vtk-python)
foreach(name ${filenames_fix_prefix})
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake")
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake" _contents)
    string(REPLACE 
[[set(_vtk_module_import_prefix "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(_vtk_module_import_prefix "${_vtk_module_import_prefix}" DIRECTORY)]]
[[set(_vtk_module_import_prefix "${CMAKE_CURRENT_LIST_DIR}")]] _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake" "${_contents}")
else()
    message(STATUS "FILE:${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake does not exist! No prefix correction!")
endif()
endforeach()

# file(INSTALL "${SOURCE_PATH}/CMake/FindPythonModules.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk/CMake)
# file(INSTALL "${SOURCE_PATH}/CMake/vtkCompilerPlatformFlags.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
# file(INSTALL "${SOURCE_PATH}/CMake/vtkEncodeString.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
#add install for CMAKE/FindPythonModules.cmake vtkCompilerPlatformFlags