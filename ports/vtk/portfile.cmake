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

if("vtkm" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKm=YES
        -DVTK_MODULE_ENABLE_VTK_vtkm=YES
    )
endif()

if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_WRAP_PYTHON=ON
        -DVTK_PYTHON_VERSION=3
        -DPython3_FIND_REGISTRY=NEVER
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=TRUE
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}"
    )

    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND ADDITIONAL_OPTIONS  "-DPython3_LIBRARY_RELEASE:PATH=${CURRENT_INSTALLED_DIR}/lib/python37.lib"
                                        "-DPython3_LIBRARY_DEBUG:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib"
                                        "-DPython3_LIBRARIES:STRING=debug\\\\\\\;${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib\\\\\\\;optimized\\\\\\\;${CURRENT_INSTALLED_DIR}/lib/python37.lib"
                                        "-DPYTHON_DEBUG_LIBRARY:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib"
                                        "-DPython3_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include/python3.7")
    elseif(VCPKG_TARGET_IS_LINUX)
        list(APPEND ADDITIONAL_OPTIONS  "-DPython3_LIBRARY_RELEASE:PATH=${CURRENT_INSTALLED_DIR}/lib/libpython37m.a"
                                        "-DPython3_LIBRARY_DEBUG:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/libpython37md.a"
                                        "-DPython3_LIBRARIES:STRING=debug\\\\\\\;${CURRENT_INSTALLED_DIR}/debug/lib/libpython37md.a\\\\\\\;optimized\\\\\\\;${CURRENT_INSTALLED_DIR}/lib/libpython37m.a"
                                        "-DPYTHON_DEBUG_LIBRARY:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/libpython37md.a"
                                        "-DPython3_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include/python3.7m")
    elseif(VCPKG_TARGET_IS_OSX)
        #Need Python3 information on OSX within VCPKG
    endif()    
    
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
    )
endif()

if("all" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "cuda"         VTK_USE_CUDA
    "all"          VTK_BUILD_ALL_MODULES
)


# =============================================================================
# Clone & patch
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/VTK
    REF ab278e87b181e3a02082bea7361fbaa3ddafb3ad # v9.0 
    SHA512 50a324f55b58bc4415f972f711420e83b41a100b27729266db4541c24bc7d7bcd27d9158ce2588178b9b2e43c20b9695ffe382605f5cde331e8371e213655164
    HEAD_REF master
    PATCHES
        FindLibHaru.patch
        FindLZMA.patch
        FindLZ4.patch
        Findproj.patch
        vtkm.patch # To include an external VTKm build (v.1.5 required)
        pegtl.patch
        ##pythonwrapper.patch # needs checking with paraview PR if still required
        ##NoUndefDebug.patch # needs checking with paraview PR if still required
        # Last patch TODO: Patch out internal loguru
)

# =============================================================================
#Overwrite outdated modules if they have not been patched:
file(COPY "${CURRENT_PORT_DIR}/FindPostgreSQL.cmake" DESTINATION "${SOURCE_PATH}/CMake")
file(COPY "${CURRENT_PORT_DIR}/FindHDF5.cmake" DESTINATION "${SOURCE_PATH}/CMake/patches/99")
# =============================================================================

# =============================================================================
# Configure & Install

# We set all libraries to "system" and explicitly list the ones that should use embedded copies
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

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# =============================================================================
# Fixup target files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/vtk-9.0)

# TODO: Check if the following is still required
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
# Remove other files and directories that are not valid for vcpkg
# if(VTK_WITH_ALL_MODULES)
    # file(REMOVE ${CURRENT_PACKAGES_DIR}/XdmfConfig.cmake)
    # file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/XdmfConfig.cmake)
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
    if(EXISTS ${old_filename})
        file(INSTALL ${old_filename} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/vtk" USE_SOURCE_PERMISSIONS)
        file(REMOVE ${old_filename})
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
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# =============================================================================
# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk/copyright)

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/vtk")

## Files Modules needed by ParaView
if("paraview" IN_LIST FEATURES)
    set(VTK_CMAKE_NEEDED vtkCompilerChecks vtkCompilerPlatformFlags vtkCompilerExtraFlags vtkInitializeBuildType vtkSupportMacros vtkDirectories vtkVersion FindPythonModules)
    foreach(module ${VTK_CMAKE_NEEDED})
        file(INSTALL "${SOURCE_PATH}/CMake/${module}.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
    endforeach()
    file(INSTALL "${SOURCE_PATH}/CMake/vtkRequireLargeFilesSupport.cxx" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
    
    #ParaView requires some internal headers
    file(INSTALL ${SOURCE_PATH}/Rendering/Annotation/vtkScalarBarActorInternal.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION})
    file(INSTALL ${SOURCE_PATH}/Filters/Statistics/vtkStatisticsAlgorithmPrivate.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION})
    file(INSTALL ${SOURCE_PATH}/Rendering/OpenGL2/vtkCompositePolyDataMapper2Internal.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION})
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Rendering/OpenGL2/vtkTextureObjectVS.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/static_python) #python headers
        file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/static_python DESTINATION ${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION})
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
