if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(WARNING "You will need to install Xorg dependencies to build vtk:\napt-get install libxt-dev\n")
endif()

include(vcpkg_common_functions)

set(VTK_SHORT_VERSION "8.2")
set(VTK_LONG_VERSION "${VTK_SHORT_VERSION}.0")
# =============================================================================
# Options:

if ("qt" IN_LIST FEATURES)
    set(VTK_WITH_QT                      ON )
else()
    set(VTK_WITH_QT                      OFF )
endif()

if ("mpi" IN_LIST FEATURES)
    set(VTK_Group_MPI ON)
else()
    set(VTK_Group_MPI OFF)
endif()

if ("python" IN_LIST FEATURES)
    set(VTK_WITH_PYTHON                  ON)
else()
    set(VTK_WITH_PYTHON                  OFF)
endif()

if("openvr" IN_LIST FEATURES)
    set(Module_vtkRenderingOpenVR ON)
else()
    set(Module_vtkRenderingOpenVR OFF)
endif()

set(VTK_WITH_ALL_MODULES                 OFF) # IMPORTANT: if ON make sure `qt5`, `mpi`, `python3`, `ffmpeg`, `gdal`, `fontconfig`,
                                              #            `libmysql` and `atlmfc` are  listed as dependency in the CONTROL file

# =============================================================================
# Clone & patch
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/VTK
    REF "v${VTK_LONG_VERSION}"
    SHA512 fd1d9c2872baa6eca7f8105b0057b56ec554e9d5eaf25985302e7fc032bdce72255d79e3f5f16ca50504151bda49cb3a148272ba32e0f410b4bdb70959b8f3f4
    HEAD_REF master
    PATCHES
        fix-find-lz4.patch
        fix_ogg_linkage.patch
        fix-pugixml-link.patch
        hdf5_static.patch
)

# Remove the FindGLEW.cmake and FindPythonLibs.cmake that are distributed with VTK,
# since they do not detect the debug libraries correctly.
# The default files distributed with CMake (>= 3.9) should be superior by all means.
# For GDAL, the one distributed with CMake does not detect the debug libraries correctly,
# so we provide an own one.
file(REMOVE ${SOURCE_PATH}/CMake/FindGLEW.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/FindPythonLibs.cmake)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindGDAL.cmake DESTINATION ${SOURCE_PATH}/CMake)

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
    )
endif()

if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(Module_vtkGUISupportMFC ON)
else()
    set(Module_vtkGUISupportMFC OFF)
endif()

# =============================================================================
# Configure & Install

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
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
        -DModule_vtkGUISupportMFC=${Module_vtkGUISupportMFC}
        -DModule_vtkRenderingOpenVR=${Module_vtkRenderingOpenVR}
        -DVTK_Group_MPI=${VTK_Group_MPI}

        ${ADDITIONAL_OPTIONS}
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
    string(REPLACE "\${_IMPORT_PREFIX}" "\${VTK_INSTALL_PREFIX}" _contents "${_contents}")
    file(WRITE "${FILE}" "${_contents}")
endforeach()

# =============================================================================
# Clean-up other directories

# Delete the debug binary TOOL_NAME that is not required
function(_vtk_remove_debug_tool TOOL_NAME)
    # on windows, the tools end with .exe
    set(filename_win ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}.exe)
    if(EXISTS ${filename_win})
        file(REMOVE ${filename_win})
    endif()
    # on other OS, it doesn't
    set(filename_unix ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME})
    if(EXISTS ${filename_unix})
        file(REMOVE ${filename_unix})
    endif()
    # we also have to bend the lines referencing the tools in VTKTargets-debug.cmake
    # to make them point to the release version of the tools
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake" VTK_TARGETS_CONTENT_DEBUG)
    string(REPLACE "debug/bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake" "${VTK_TARGETS_CONTENT_DEBUG}")
endfunction()

# Move the release binary TOOL_NAME from bin to tools
function(_vtk_move_release_tool TOOL_NAME)
    # on windows, the tools end with .exe
    set(old_filename_win "${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}.exe")
    if(EXISTS ${old_filename_win})
        file(INSTALL ${old_filename_win} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/vtk")
        file(REMOVE ${old_filename_win})
    endif()
    # on other OS, it doesn't
    set(old_filename_unix "${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}")
    if(EXISTS ${old_filename_unix})
        file(INSTALL ${old_filename_unix} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/vtk")
        file(REMOVE ${old_filename_unix})
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
