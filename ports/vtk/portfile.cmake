if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "You will need to install Xorg dependencies to build vtk:\napt-get install libxt-dev\n")
endif()

set(VTK_SHORT_VERSION "8.2")
set(VTK_LONG_VERSION "${VTK_SHORT_VERSION}.0")
# =============================================================================
# Options:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    qt     VTK_GROUP_ENABLE_Qt
    mpi    VTK_Group_MPI
    python VTK_WITH_PYTHON
    openvr Module_vtkRenderingOpenVR
    atlmfc Module_vtkGUISupportMFC 
    paraview Module_vtkIOParallelExodus:BOOL
    paraview Module_vtkRenderingParallel:BOOL
    paraview Module_vtkRenderingVolumeAMR:BOOL
    
)
#    paraview VTK_ENABLE_KITS:BOOL 
#    paraview Module_vtkUtilitiesEncodeString:BOOL
#INVERTED_FEATURES
#    paraview VTK_USE_SYSTEM_PUGIXML:BOOL # Bug in VTK 8.2.0 fixed in master but the macro for it was complelty changed so it cannot be transfered. 

set(VTK_WITH_ALL_MODULES                 OFF) # IMPORTANT: if ON make sure `qt5`, `mpi`, `python3`, `ffmpeg`, `gdal`, `fontconfig`,
                                              #            `libmysql` and `atlmfc` are  listed as dependency in the CONTROL file

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
        #fix-find-lz4.patch
        #fix_ogg_linkage.patch
        #fix-pugixml-link.patch #TARGETS do not work correctly in VTK!!!!
        #hdf5_static.patch
        #fix-find-lzma.patch
        #fix-proj4.patch
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
# Collect CMake options for optional components
if(VTK_WITH_QT)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_Group_Qt=ON
        -DVTK_QT_VERSION=5
        -DVTK_BUILD_QT_DESIGNER_PLUGIN=OFF
    )
endif()

if(VTK_WITH_PYTHON)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_WRAP_PYTHON=ON
        -DVTK_PYTHON_VERSION=3
    )
endif()

if(VTK_WITH_ALL_MODULES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_BUILD_ALL_MODULES=ON
        -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
        # -DVTK_USE_SYSTEM_AUTOBAHN=ON
        # -DVTK_USE_SYSTEM_SIX=ON
        # -DVTK_USE_SYSTEM_MPI4PY=ON
        # -DVTK_USE_SYSTEM_CONSTANTLY=ON
        # -DVTK_USE_SYSTEM_INCREMENTAL=ON
        # -DVTK_USE_SYSTEM_TWISTED=ON
        # -DVTK_USE_SYSTEM_XDMF2=ON
        # -DVTK_USE_SYSTEM_XDMF3=ON
        # -DVTK_USE_SYSTEM_ZFP=ON
        # -DVTK_USE_SYSTEM_ZOPE=ON
        # -DVTK_USE_SYSTEM_LIBPROJ=ON
    )
endif()

include(SelectLibraryConfigurations)
find_library(PROJ_LIBRARY_RELEASE proj proj4 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(PROJ_LIBRARY_DEBUG proj proj4 proj_d proj4_d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
select_library_configurations(PROJ)
find_library(PUGIXML_LIBRARY_RELEASE pugixml PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(PUGIXML_LIBRARY_DEBUG pugixml PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
select_library_configurations(PUGIXML)
# =============================================================================
# Configure & Install
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DVTK_BUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DVTK_INSTALL_INCLUDE_DIR=include
        -DVTK_INSTALL_DATA_DIR=share/vtk/data
        -DVTK_INSTALL_DOC_DIR=share/vtk/doc
        -DVTK_INSTALL_PACKAGE_DIR=share/vtk
        -DVTK_INSTALL_RUNTIME_DIR=bin
        -DVTK_FORBID_DOWNLOADS=ON

        # We set all libraries to "system" and explicitly list the ones that should use embedded copies
        -DVTK_USE_SYSTEM_LIBRARIES=ON
        -DVTK_USE_SYSTEM_GL2PS=OFF

        # Select modules / groups to install
        -DVTK_Group_Imaging=ON
        -DVTK_Group_Views=ON
        -DPYTHON_EXECUTABLE=${PYTHON3}

        ${ADDITIONAL_OPTIONS}
        -DPROJ_LIBRARY=${PROJ_LIBRARY}
        
        #-DVTK_USE_SYSTEM_PUGIXML:BOOL=OFF
        -DPUGIXML_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        #-DPUGIXML_LIBRARIES=${PUGIXML_LIBRARY}
        #-DPUGIXML_LIBRARY=${PUGIXML_LIBRARY}
        -Dpugixml_LIBRARIES=${PUGIXML_LIBRARY}
        #-Dpugixml_LIBRARY=${PUGIXML_LIBRARY}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# =============================================================================
# Fixup target files
vcpkg_fixup_cmake_targets()

# For some reason the references to the XDMF libraries in the target files do not end up
# correctly, so we fix them here.
if(VTK_WITH_ALL_MODULES)
    file(READ ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake VTK_TARGETS_RELEASE_CONTENT)
    string(REPLACE "lib/../XdmfCore.lib" "lib/XdmfCore.lib" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    string(REPLACE "bin/../XdmfCore.dll" "bin/XdmfCore.dll" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    string(REPLACE "lib/../vtkxdmf3.lib" "lib/vtkxdmf3.lib" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    string(REPLACE "bin/../vtkxdmf3.dll" "bin/vtkxdmf3.dll" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake "${VTK_TARGETS_RELEASE_CONTENT}")

    file(READ ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake VTK_TARGETS_DEBUG_CONTENT)
    string(REPLACE "lib/../XdmfCore.lib" "lib/XdmfCore.lib" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    string(REPLACE "bin/../XdmfCore.dll" "bin/XdmfCore.dll" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    string(REPLACE "lib/../vtkxdmf3.lib" "lib/vtkxdmf3.lib" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    string(REPLACE "bin/../vtkxdmf3.dll" "bin/vtkxdmf3.dll" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake "${VTK_TARGETS_DEBUG_CONTENT}")
endif()

#file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets.cmake" VTK_TARGETS_CONTENT)
# Remove unset of _IMPORT_PREFIX in VTKTargets.cmake
#_IMPORT_PREFIX is required by vtkModules due to vcpkg_fixup_cmake_targets changing all cmake files (to use _IMPORT_PREFIX). 
#STRING(REPLACE [[set(_IMPORT_PREFIX)]] 
#[[
# VCPKG: The value of _IMPORT_PREFIX should not be unset.
#set(_IMPORT_PREFIX)
#]]
#VTK_TARGETS_CONTENT "${VTK_TARGETS_CONTENT}")
#file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets.cmake" "${VTK_TARGETS_CONTENT}")

#file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets.cmake" VTK_TARGETS_CONTENT)

# Fix _IMPORT_PREFIX. It is not set within the Modules cmake (only set in VTKTargets.cmake).
# Since for VCPKG _IMPORT_PREFIX == VTK_INSTALL_PREFIX we just replace it with that.
file(GLOB_RECURSE CMAKE_FILES ${CURRENT_PACKAGES_DIR}/share/vtk/Modules/*.cmake)
foreach(FILE IN LISTS CMAKE_FILES)
    file(READ "${FILE}" _contents)
    file(WRITE "${FILE}.bak" "${_contents}")
    string(REPLACE "\${_IMPORT_PREFIX}" "\${VTK_INSTALL_PREFIX}" _contents "${_contents}")
    file(WRITE "${FILE}" "${_contents}")
endforeach()

# Correct 3rd Party modules in *.cmake:
set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtkdoubleconversion.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/double-conversion.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/double-conversion.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/double-conversion.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtkexpat.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/expat.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/expat.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/expat.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtkjsoncpp.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/jsoncpp.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/jsoncpp.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/jsoncpp.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtklibproj.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/proj.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/proj.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/proj_d.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtklibxml2.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/libxml2.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/libxml2.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/libxml2.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtknetcdf.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/netcdf.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/netcdf.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/netcdf.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtkogg.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/ogg.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/ogg.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/ogg.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtksqlite.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/sqlite3.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/sqlite3.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/sqlite3.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

set(FILE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtktheora.cmake")
file(READ "${FILE}" _contents)
string(REPLACE [["${VTK_INSTALL_PREFIX}/lib/theoraenc.lib;${VTK_INSTALL_PREFIX}/lib/theoradec.lib"]] 
               [[optimized;"${VTK_INSTALL_PREFIX}/lib/theoraenc.lib";optimized;"${VTK_INSTALL_PREFIX}/lib/theoradec.lib";debug;"${VTK_INSTALL_PREFIX}/debug/lib/theoraenc.lib;";debug;"${VTK_INSTALL_PREFIX}/debug/lib/theoradec.lib"]] 
               _contents "${_contents}")
file(WRITE "${FILE}" "${_contents}")

# =============================================================================
# Clean-up other directories

# Delete the debug binary TOOL_NAME that is not required
function(_vtk_remove_debug_tool TOOL_NAME)
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE ${filename})
    endif()
    # we also have to bend the lines referencing the tools in VTKTargets-debug.cmake
    # to make them point to the release version of the tools
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake" VTK_TARGETS_CONTENT_DEBUG)
    string(REPLACE "debug/bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake" "${VTK_TARGETS_CONTENT_DEBUG}")
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
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake" VTK_TARGETS_CONTENT_RELEASE)
    string(REPLACE "bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_RELEASE "${VTK_TARGETS_CONTENT_RELEASE}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake" "${VTK_TARGETS_CONTENT_RELEASE}")
endfunction()

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
    vtkpython
    pvtkpython
)

foreach(TOOL_NAME IN LISTS VTK_TOOLS)
    _vtk_remove_debug_tool("${TOOL_NAME}")
    _vtk_move_release_tool("${TOOL_NAME}")
endforeach()

file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtkhdf5.cmake" _contents)
string(REPLACE "vtk::hdf5::hdf5_hl" "" _contents "${_contents}")
string(REPLACE "vtk::hdf5::hdf5" "" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/vtkhdf5.cmake" "${_contents}")

# =============================================================================
# Remove other files and directories that are not valid for vcpkg
if(VTK_WITH_ALL_MODULES)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/XdmfConfig.cmake)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/XdmfConfig.cmake)
endif()

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

file(INSTALL "${SOURCE_PATH}/CMake/FindPythonModules.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk/CMake)
file(INSTALL "${SOURCE_PATH}/CMake/vtkCompilerPlatformFlags.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
file(INSTALL "${SOURCE_PATH}/CMake/vtkEncodeString.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
#add install for CMAKE/FindPythonModules.cmake vtkCompilerPlatformFlags