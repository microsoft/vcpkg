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
        -DVTK_MODULE_ENABLE_VTK_GUISupportQt=YES
        -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingQt=YES
        -DVTK_MODULE_ENABLE_VTK_ViewsQt=YES
    )

endif()
if("atlmfc" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_GUISupportMFC=YES
    )
endif()
if("vtkm" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore=YES
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel=YES
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters=YES
        -DVTK_MODULE_ENABLE_VTK_vtkm=YES
    )
endif()

if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_WRAP_PYTHON=ON
        -DVTK_PYTHON_VERSION=3
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}"
        -DVTK_MODULE_ENABLE_VTK_Python=YES
        -DVTK_MODULE_ENABLE_VTK_PythonContext2D=YES
        -DVTK_MODULE_ENABLE_VTK_PythonInterpreter=YES
    )
    #VTK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages
endif()

if("paraview" IN_LIST FEATURES)
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
        -DVTK_MODULE_ENABLE_VTK_RenderingAnnotation=YES
        -DVTK_MODULE_ENABLE_VTK_DomainsChemistry=YES
        -DVTK_MODULE_ENABLE_VTK_DomainsChemistryOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_FiltersParallelDIY2=YES
    )
    if("python" IN_LIST FEATURES)
        list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib=YES
        )
    endif()
endif()

if("mpi" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_GROUP_ENABLE_MPI=YES
        -DVTK_USE_MPI=YES
    )
endif()

if("mpi" IN_LIST FEATURES AND "python" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_USE_EXTERNAL_VTK_mpi4py=OFF
    )
endif()

if("opengl" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_DomainsChemistryOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_ImagingOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingGL2PSOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingLICOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_opengl=YES
        )
endif()

if ("openvr" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS    
        -DVTK_MODULE_ENABLE_VTK_RenderingOpenVR=YES
    )
endif()

if("cuda" IN_LIST FEATURES AND CMAKE_HOST_WIN32)
    vcpkg_add_to_path("$ENV{CUDA_PATH}/bin")
endif()

if("utf8" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DKWSYS_ENCODING_DEFAULT_CODEPAGE=CP_UTF8
    )
endif()

if("all" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "cuda"         VTK_USE_CUDA
        "all"          VTK_BUILD_ALL_MODULES
)


# =============================================================================
# Clone & patch


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/VTK
    REF 2959413ff190bc6e3ff40f5b6c1342edd2e5233f # v9.0.x used by ParaView 5.9.1
    SHA512 16229c107ed904e8fa6850c3814b8bdcdf9700ef44f6ff5b3a77e7d793ce19954fc2c7b1219a0162cf588def6e990883cd3f808c316a4db6e65bd6cd1769dd3f
    HEAD_REF master
    PATCHES
        FindLZMA.patch
        FindLZ4.patch
        Findproj.patch
        pegtl.patch
        pythonwrapper.patch # Required by ParaView to Wrap required classes
        NoUndefDebug.patch # Required to link against correct Python library depending on build type.
        python_debug.patch
        fix-using-hdf5.patch
        # CHECK: module-name-mangling.patch
        # Last patch TODO: Patch out internal loguru
        FindExpat.patch # The find_library calls are taken care of by vcpkg-cmake-wrapper.cmake of expat
        # upstream vtkm patches to make it work with vtkm 1.6
        vtkm.patch # To include an external VTKm build
        1f00a0c9.patch
        156fb524.patch
        d107698a.patch
)

# =============================================================================
#Overwrite outdated modules if they have not been patched:
file(COPY "${CURRENT_PORT_DIR}/FindHDF5.cmake" DESTINATION "${SOURCE_PATH}/CMake/patches/99") # due to usage of targets in netcdf-c
# =============================================================================

# =============================================================================
# Configure & Install

# We set all libraries to "system" and explicitly list the ones that should use embedded copies
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DVTK_BUILD_TESTING=OFF
        -DVTK_BUILD_EXAMPLES=OFF
        -DVTK_FORBID_DOWNLOADS=ON
        -DVTK_ENABLE_REMOTE_MODULES=OFF
        # VTK groups to enable
        -DVTK_GROUP_ENABLE_StandAlone=YES
        -DVTK_GROUP_ENABLE_Rendering=YES
        -DVTK_GROUP_ENABLE_Views=YES
        # Disable deps not in VCPKG
        -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
        # Select modules / groups to install
        -DVTK_USE_EXTERNAL:BOOL=ON
        -DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps:BOOL=OFF # Not yet in VCPKG
        ${ADDITIONAL_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# =============================================================================
# Fixup target files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vtk-9.0)

# =============================================================================
# Clean-up other directories

# Delete the debug binary TOOL_NAME that is not required
function(_vtk_remove_debug_tool TOOL_NAME)
    set(filename "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(EXISTS "${filename}")
        file(REMOVE "${filename}")
    endif()
    set(filename "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}d${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(EXISTS "${filename}")
        file(REMOVE "${filename}")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        # we also have to bend the lines referencing the tools in VTKTargets-debug.cmake
        # to make them point to the release version of the tools
        file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-debug.cmake" VTK_TARGETS_CONTENT_DEBUG)
        string(REPLACE "debug/bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
        string(REPLACE "tools/vtk/${TOOL_NAME}d" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-debug.cmake" "${VTK_TARGETS_CONTENT_DEBUG}")
    endif()
endfunction()

# Move the release binary TOOL_NAME from bin to tools
function(_vtk_move_release_tool TOOL_NAME)
    set(old_filename "${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(EXISTS "${old_filename}")
        file(INSTALL "${old_filename}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/vtk" USE_SOURCE_PERMISSIONS)
        file(REMOVE "${old_filename}")
    endif()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        # we also have to bend the lines referencing the tools in VTKTargets-release.cmake
        # to make them point to the tool folder
        file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-release.cmake" VTK_TARGETS_CONTENT_RELEASE)
        string(REPLACE "bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_RELEASE "${VTK_TARGETS_CONTENT_RELEASE}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-release.cmake" "${VTK_TARGETS_CONTENT_RELEASE}")
    endif()
endfunction()

set(VTK_SHORT_VERSION 9.0)
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
# TODO: Replace with vcpkg_copy_tools if known which tools are built with which feature
# or add and option to vcpkg_copy_tools which does not require the tool to be present
foreach(TOOL_NAME IN LISTS VTK_TOOLS)
    _vtk_remove_debug_tool("${TOOL_NAME}")
    _vtk_move_release_tool("${TOOL_NAME}")
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin"
                        "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/vtk")

## Files Modules needed by ParaView
if("paraview" IN_LIST FEATURES)
    set(VTK_CMAKE_NEEDED vtkCompilerChecks vtkCompilerPlatformFlags vtkCompilerExtraFlags vtkInitializeBuildType
                         vtkSupportMacros vtkVersion FindPythonModules vtkModuleDebugging vtkExternalData)
    foreach(module ${VTK_CMAKE_NEEDED})
        file(INSTALL "${SOURCE_PATH}/CMake/${module}.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/vtk")
    endforeach()

    ## Check List on UPDATE !!
    file(INSTALL "${SOURCE_PATH}/CMake/vtkRequireLargeFilesSupport.cxx" DESTINATION "${CURRENT_PACKAGES_DIR}/share/vtk")
    file(INSTALL "${SOURCE_PATH}/Rendering/Volume/vtkBlockSortHelper.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}") # this should get installed by VTK
    file(INSTALL "${SOURCE_PATH}/Filters/ParallelDIY2/vtkDIYKdTreeUtilities.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}")
    file(INSTALL "${SOURCE_PATH}/Parallel/DIY/vtkDIYUtilities.txx" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}")

    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Rendering/OpenGL2/vtkTextureObjectVS.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}")

endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/vtkpythonmodules/static_python) #python headers
        file(GLOB_RECURSE STATIC_PYTHON_FILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/*/static_python/*.h")
        file(INSTALL ${STATIC_PYTHON_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION})
    endif()
endif()

#remove one get_filename_component(_vtk_module_import_prefix "${_vtk_module_import_prefix}" DIRECTORY) from vtk-prefix.cmake and VTK-vtk-module-properties and vtk-python.cmake
set(filenames_fix_prefix vtk-prefix VTK-vtk-module-properties vtk-python)
foreach(name IN LISTS filenames_fix_prefix)
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake")
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake" _contents)
    string(REPLACE
[[set(_vtk_module_import_prefix "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(_vtk_module_import_prefix "${_vtk_module_import_prefix}" DIRECTORY)]]
[[set(_vtk_module_import_prefix "${CMAKE_CURRENT_LIST_DIR}")]] _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake" "${_contents}")
else()
    debug_message("FILE:${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake does not exist! No prefix correction!")
endif()
endforeach()

# Use vcpkg provided find method
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/FindEXPAT.cmake")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/licenses" "${CURRENT_PACKAGES_DIR}/share/${PORT}/licenses")

# =============================================================================
# Usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
# Handle copyright
file(INSTALL "${SOURCE_PATH}/Copyright.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
