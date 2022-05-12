file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON _ver_string GET "${_vcpkg_json}" "version-semver")
string(REGEX MATCH "^[0-9]+\.[0-9]+" VERSION "${_ver_string}")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "You will need to install Xorg dependencies to build vtk:\napt-get install libxt-dev\n")
endif()

# =============================================================================
# Clone & patch
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/VTK
    REF 285daeedd58eb890cb90d6e907d822eea3d2d092 # v9.1.0
    SHA512 4eecbd1b0a0235cec62b0fdd47c2262d637ea6d298b94bb87b5915c2640c6c6d9d3f08e2136d93f1062885b2bffc282f27a326f4475df047ba5fbe5354770716
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
        fix-gdal.patch
        missing-limits.patch # This patch can be removed in next version. Since it has been merged to upstream via https://gitlab.kitware.com/vtk/vtk/-/merge_requests/7611
        UseProj5Api.patch # Allow Proj 8.0+ (commit b66e4a7, backported). Should be in soon after 9.0.3
        fix-find-libharu.patch
        cgns.patch
        f541a38.patch # include vtkParseAttributes.h & vtkWraText.h in headers. See https://github.com/Kitware/VTK/commit/f541a3809fc6b1b3e99063f2345ea11c118637f1
)

# =============================================================================
#Overwrite outdated modules if they have not been patched:
file(COPY "${CURRENT_PORT_DIR}/FindHDF5.cmake" DESTINATION "${SOURCE_PATH}/CMake/patches/99") # due to usage of targets in netcdf-c
# =============================================================================

# =============================================================================
# Options:
# Collect CMake options for optional components

# TODO:
# - add loguru as a dependency requires #8682
vcpkg_check_features(OUT_FEATURE_OPTIONS VTK_FEATURE_OPTIONS
    FEATURES
        "qt"          VTK_GROUP_ENABLE_Qt
        "qt"          VTK_MODULE_ENABLE_VTK_GUISupportQt
        "qt"          VTK_MODULE_ENABLE_VTK_GUISupportQtSQL
        "qt"          VTK_MODULE_ENABLE_VTK_RenderingQt
        "qt"          VTK_MODULE_ENABLE_VTK_ViewsQt
        "qtquick"     VTK_MODULE_ENABLE_VTK_GUISupportQtQuick
        "atlmfc"      VTK_MODULE_ENABLE_VTK_GUISupportMFC
        "vtkm"        VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore
        "vtkm"        VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel
        "vtkm"        VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters
        "vtkm"        VTK_MODULE_ENABLE_VTK_vtkm
        "python"      VTK_MODULE_ENABLE_VTK_Python
        "python"      VTK_MODULE_ENABLE_VTK_PythonContext2D
        "python"      VTK_MODULE_ENABLE_VTK_PythonInterpreter
        "paraview"    VTK_MODULE_ENABLE_VTK_FiltersParallelStatistics
        "paraview"    VTK_MODULE_ENABLE_VTK_IOParallelExodus
        "paraview"    VTK_MODULE_ENABLE_VTK_RenderingParallel
        "paraview"    VTK_MODULE_ENABLE_VTK_RenderingVolumeAMR
        "paraview"    VTK_MODULE_ENABLE_VTK_IOXdmf2
        "paraview"    VTK_MODULE_ENABLE_VTK_IOH5part
        "paraview"    VTK_MODULE_ENABLE_VTK_IOParallelLSDyna
        "paraview"    VTK_MODULE_ENABLE_VTK_IOTRUCHAS
        "paraview"    VTK_MODULE_ENABLE_VTK_IOVPIC
        "paraview"    VTK_MODULE_ENABLE_VTK_RenderingAnnotation
        "paraview"    VTK_MODULE_ENABLE_VTK_DomainsChemistry
        "paraview"    VTK_MODULE_ENABLE_VTK_FiltersParallelDIY2
        "paraview"    VTK_MODULE_ENABLE_VTK_cli11
        "mpi"         VTK_GROUP_ENABLE_MPI
        "opengl"      VTK_MODULE_ENABLE_VTK_ImagingOpenGL2
        "opengl"      VTK_MODULE_ENABLE_VTK_RenderingGL2PSOpenGL2
        "opengl"      VTK_MODULE_ENABLE_VTK_RenderingOpenGL2
        "opengl"      VTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2
        "opengl"      VTK_MODULE_ENABLE_VTK_opengl
        "openvr"      VTK_MODULE_ENABLE_VTK_RenderingOpenVR
        "gdal"        VTK_MODULE_ENABLE_VTK_IOGDAL
        "geojson"     VTK_MODULE_ENABLE_VTK_IOGeoJSON
)

# Replace common value to vtk value
list(TRANSFORM VTK_FEATURE_OPTIONS REPLACE "=ON" "=YES")
list(TRANSFORM VTK_FEATURE_OPTIONS REPLACE "=OFF" "=DONT_WANT")

if("qt" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_QT_VERSION:STRING=5
    )
endif()

if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_WRAP_PYTHON=ON
        -DVTK_PYTHON_VERSION=3
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}"
    )
    #VTK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages
endif()

if ("paraview" IN_LIST FEATURES OR "opengl" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingLICOpenGL2=YES
        -DVTK_MODULE_ENABLE_VTK_DomainsChemistryOpenGL2=YES
    )
endif()

if("paraview" IN_LIST FEATURES AND "python" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib=YES
    )
endif()

if("mpi" IN_LIST FEATURES AND "python" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_USE_EXTERNAL_VTK_mpi4py=OFF
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
        -DVTK_FORBID_DOWNLOADS=OFF
    )
else()
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_FORBID_DOWNLOADS=ON
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "cuda"         VTK_USE_CUDA
        "mpi"          VTK_USE_MPI
        "all"          VTK_BUILD_ALL_MODULES
)

# =============================================================================
# Configure & Install

# We set all libraries to "system" and explicitly list the ones that should use embedded copies
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${VTK_FEATURE_OPTIONS}
        -DVTK_BUILD_EXAMPLES=OFF
        -DVTK_BUILD_TESTING=OFF
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
        -DVTK_MODULE_USE_EXTERNAL_VTK_ioss:BOOL=OFF # Not yet in VCPKG
        -DVTK_MODULE_ENABLE_VTK_RenderingRayTracing=DONT_WANT # ospray is not yet in VCPKG
        ${ADDITIONAL_OPTIONS}
        -DVTK_DEBUG_MODULE_ALL=ON
        -DVTK_DEBUG_MODULE=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# =============================================================================
# Fixup target files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vtk-${VERSION})

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

set(VTK_SHORT_VERSION ${VERSION})
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
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/vtkpythonmodules/static_python") #python headers
        file(GLOB_RECURSE STATIC_PYTHON_FILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/*/static_python/*.h")
        file(INSTALL ${STATIC_PYTHON_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}")
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

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/qml/VTK.${VERSION}/qmlvtkplugin.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/qml/VTK.${VERSION}/qmlvtkplugin.dll" "${CURRENT_PACKAGES_DIR}/bin/qmlvtkplugin.dll")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/qml/VTK.${VERSION}/qmlvtkplugin.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/qml/VTK.${VERSION}/qmlvtkplugin.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/qmlvtkplugin.dll")
endif()

# Use vcpkg provided find method
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/FindEXPAT.cmake")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/licenses" "${CURRENT_PACKAGES_DIR}/share/${PORT}/licenses")

if(EXISTS "${CURRENT_PACKAGES_DIR}/include/vtk-${VERSION}/vtkChemistryConfigure.h")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/vtk-${VERSION}/vtkChemistryConfigure.h" "${SOURCE_PATH}" "not/existing")
endif()
# =============================================================================
# Usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
# Handle copyright
file(INSTALL "${SOURCE_PATH}/Copyright.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
